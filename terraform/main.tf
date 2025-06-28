terraform {
  backend "s3" {
    key          = "devops-unisatc-a3/terraform.tfstate"
    region       = "sa-east-1"
    bucket       = "joelfrancisco-terraform-state"
    use_lockfile = true
  }

  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.51.0"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "app-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "app-igw" }
}

data "aws_availability_zones" "azs" {}

resource "aws_subnet" "public" {
  count = 2
  map_public_ip_on_launch = true
  for_each                = toset(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.azs.names[index(var.public_subnet_cidrs, each.value)]
  tags                    = { Name = "public-${each.value}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

## Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.this.id
  description = "Allow HTTP from anywhere"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  vpc_id      = aws_vpc.this.id
  description = "Allow ECS traffic from ALB"

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## ECR Repository
resource "aws_ecr_repository" "app" {
  name                 = replace(var.service_name, "/", "-")
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  encryption_configuration { encryption_type = "AES256" }
}

## ECS Cluster and Task Role
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "task_exec" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "exec_attach" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## ALB and Target Group
resource "aws_lb" "alb" {
  name            = "${var.service_name}-alb"
  internal        = false
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = values(aws_subnet.public)[*].id
  load_balancer_type = "application"
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.service_name}-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = "traffic-port"
    healthy_threshold   = 2
    interval            = 30
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

## ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_exec.arn

  container_definitions = jsonencode([
    {
      name         = var.service_name
      image        = "${aws_ecr_repository.app.repository_url}:latest"
      essential    = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
      environment = [
        { name  = "HOST", value = "0.0.0.0" },
        { name  = "PORT", value = "1337" },
        { name  = "DATABASE_CLIENT", value = "sqlite" },
        { name  = "DATABASE_FILENAME", value = ".tmp/data.db" },
        { name  = "APP_KEYS", value = var.app_keys },
        { name  = "API_TOKEN_SALT", value = var.api_token_salt },
        { name  = "ADMIN_JWT_SECRET", value = var.admin_jwt_secret },
        { name  = "TRANSFER_TOKEN_SALT", value = var.transfer_token_salt },
        { name  = "JWT_SECRET", value = var.jwt_secret }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

## ECS Service
resource "aws_ecs_service" "app" {
  name                              = var.service_name
  cluster                           = aws_ecs_cluster.this.id
  task_definition                   = aws_ecs_task_definition.app.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = values(aws_subnet.public)[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }
}
