# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform RDS Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-rds/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-rds.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-rds.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-rds/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform wrapper for RDS simplifies the configuration of the Relational Database Service in the AWS cloud. This wrapper functions as a predefined template, facilitating the creation and management of RDS instances by handling all the technical details.

### ✨ Features

- 🔐 [User and Database Management](#user-and-database-management) - Manages users, databases, and access with credential storage and notifications

- 💾 [Dump with S3](#dump-with-s3) - Generates SQL dumps and stores them in S3 for MySQL, MariaDB, and PostgreSQL

- 💾 [Restore with S3](#restore-with-s3) - Restores database from SQL dump and executes cleanup scripts

- 🌐 [DNS Record](#dns-record) - Registers a CNAME DNS record in a Route53 hosted zone

- 🕰️ [Enrollment of Point in Time Recovery](#enrollment-of-point-in-time-recovery) - Enables Point in Time Recovery backup policy integration



### 🔗 External Modules
| Name | Version |
|------|------:|
| [terraform-aws-modules/eventbridge/aws](https://github.com/terraform-aws-modules/eventbridge-aws) | 4.1.0 |
| [terraform-aws-modules/lambda/aws](https://github.com/terraform-aws-modules/lambda-aws) | 8.0.1 |
| [terraform-aws-modules/lambda/aws](https://github.com/terraform-aws-modules/lambda-aws) | 7.19.0 |
| [terraform-aws-modules/rds/aws](https://github.com/terraform-aws-modules/rds-aws) | 6.9.0 |
| [terraform-aws-modules/s3-bucket/aws](https://github.com/terraform-aws-modules/s3-bucket-aws) | 5.2.0 |
| [terraform-aws-modules/security-group/aws](https://github.com/terraform-aws-modules/security-group-aws) | 5.3.0 |
| [terraform-aws-modules/ssm-parameter/aws](https://github.com/terraform-aws-modules/ssm-parameter-aws) | 1.1.2 |



## 🚀 Quick Start
```hcl
rds_parameters = {
  ## Nombre y definición de una instancia RDS
  "00" = {
    
    ## Definiciones para la creación del motor
    engine                 = "mariadb"
    engine_version         = "10.6.14"
    instance_class         = "db.t3.micro"
    deletion_protection    = true
    publicly_accessible    = false
    
    ## Definición de subnets sobre las cuales se desplegará y accederá al motor
    ## Definido por ids
    subnet_ids             = data.aws_subnets.public.ids
    ## Definido por nombre
    # subnet_name = "${local.common_name_prefix}-db*" # Default: "${local.common_name_prefix}-private*"
    
    ## Reglas de acceso para el recurso
    ingress_with_cidr_blocks = [
      {
        rule        = "mysql-tcp"
        cidr_blocks = "172.1.0.0/16"
      }
    ]
    
    ## Definición de tamaño y tipo de storage para el motor
    allocated_storage     = 5
    max_allocated_storage = 10
    storage_type          = null
    
    ## Parametros que utilizara el motor
    parameters = [
      {
        name  = "max_connections"
        value = "150"
      }
    ]
    ## Definiciones de ventanas de mantenimiento y backup
    maintenance_window      = "Sun:04:00-Sun:06:00"
    backup_window           = "03:00-03:30"
    backup_retention_period = "7"
    apply_immediately       = false
    
    ## Habilitación y retención de servicio de performance insights
    #performance_insights_enabled           = false
    #performance_insights_retention_period  = 7
  }
}

rds_defaults = var.rds_defaults
```


## 🔧 Additional Features Usage

### User and Database Management
Deploy a lambda function that manages the creation and modification of *Users*, *Databases*, and their access to them.
The credentials for the accesses will be stored in a parameter of **Parameter Store**.
Send notifications of the actions taken.
Does not remove databases or users; the latter will remain without permissions on the resources.


<details><summary>MySQL / MariaDB code</summary>

```hcl
rds_parameters = {
  "mysql" = {
    ...
    enable_db_management                    = true
    enable_db_management_logs_notifications = true
    db_management_parameters = {
      databases = [
        {
          name    = "mydb1"
          charset = "utf8mb4"
          collate = "utf8mb4_general_ci"
        },
        {
          name    = "mydb2"
          charset = "utf8mb4"
          collate = "utf8mb4_general_ci"
        }
      ],
      users = [
        {
          username = "user1"
          host     = "%"
          password = "password1"
          grants = [
            {
              database   = "mydb1"
              table      = "*"
              privileges = "ALL"
            },
            {
              database   = "mydb2"
              table      = "*"
              privileges = "SELECT, UPDATE"
            }
          ]
        },
        {
          username = "user2"
          host     = "%"
          password = "password2"
          grants = [
            {
              database   = "mydb2"
              table      = "*"
              privileges = "ALL"
            }
          ]
        }
      ],
      excluded_users = ["rdsadmin", "root", "mariadb.sys", "healthcheck", "rds_superuser_role", "mysql.infoschema", "mysql.session", "mysql.sys"]
    }
    ...
  }
}
```


</details>

<details><summary>PostgreSQL code</summary>

```hcl
rds_parameters = {
  "postgresql" = {
    ...
    enable_db_management                    = true
    enable_db_management_logs_notifications = true
    db_management_parameters = {
      databases = [
        {
          "name" : "db1",
          "owner" : "root",
          "schemas" : [
            {
              "name" : "public",
              "owner" : "root"
            },
            {
              "name" : "schema1",
              "owner" : "usr1"
            }
          ]
        },
        {
          "name" : "db2",
          "owner" : "usr2",
        },
        {
          "name" : "db3",
          "owner" : "usr3",
        }
      ],
      roles = [
        { "rolename" : "example_role_1" },
        { "rolename" : "example_role_2" }
      ],
      users = [
        {
          "username" : "usr1",
          "password" : "passwd1",
          "grants" : [
            {
              "database" : "db1",
              "schema" : "public",
              "privileges" : "ALL PRIVILEGES",
              "table" : "*"
            }
          ]
        },
        {
          "username" : "usr2",
          "password" : "passwd2",
          "grants" : [
            {
              "privileges" : "example_role_1",
              "options" : "WITH SET TRUE"
            },
            {
              "privileges" : "example_role_2",
              "options" : "WITH SET TRUE"
            }
          ]
        },
        {
          "username" : "usr3",
          "password" : "passwd3",
          "grants" : []
        }
      ],
      excluded_users = ["rdsadmin", "root", "healthcheck"]
    }
    ...
  }
}
```


</details>


### Dump with S3
This module creates the necessary resources to generate an SQL dump and store it in an S3 bucket, along with cleanup scripts for the database. <br/> It supports the database engines **MySQL**, **MariaDB**, and **PostgreSQL**.


<details><summary>Configuration Code</summary>

```hcl
rds_parameters = {
  "00" = {
    ...
    enable_db_dump_create = true
    db_dump_create_local_path_custom_scripts = "${path.module}/content/custom_sql"
    db_dump_create_schedule_expression = "cron(0 * * * ? *)"
    db_dump_create_db_name = "demo"
    db_dump_create_retention_in_days = 7
    db_dump_create_s3_arn_permission_accounts = [
      "arn:aws:iam::xxxxxxxxxxx:root", # demo.la-dev
      "arn:aws:iam::xxxxxxxxxxx:root", # demo.la-stg
    ]
    ...
  }
}
```


</details>


### Restore with S3
This module creates the necessary resources to perform a restore from an SQL dump stored in a bucket and execute the necessary cleanup scripts. <br/> It supports the database engines **MySQL**, **MariaDB**, and **PostgreSQL**


<details><summary>Configuration Code</summary>

```hcl
enable_db_dump_restore = true
db_dump_restore_s3_bucket_name = "demo-l04-core-00-db-dump-create"
db_dump_restore_db_name = "demo"
```


</details>


### DNS Record
Register a CNAME DNS record in a Route53 hosted zone that is present within the account, which can be public or private depending on the desired visibility type of the record.


<details><summary>Configuration Code</summary>

```hcl
dns_records = {
  "" = {
    # zone_name    = local.zone_private
    # private_zone = true
    zone_name    = local.zone_public
    private_zone = false
  }
}
```


</details>


### Enrollment of Point in Time Recovery
This tag allows the resource to be added to a backup policy of the Point in Time Recovery type. It requires the policy to be deployed with AWS Backups and the tag to be used.


<details><summary>Configuration Code</summary>

```hcl
tags = { ptr-14d = "true" }
```


</details>










## ⚠️ Important Notes
- **🚨 Restart Engine During Changes:** Restart the engine during parameter group changes - set `apply_immediately = true`
- **⚠️ Public Access:** Exposes the resource to the internet - set `publicly_accessible = true`
- **⚠️ Overwrite Database Data:** Allows overwriting database contents within the engine - set `allow_overwrite = true`
- **ℹ️ Storage Growth Limit:** Enables unlimited storage growth - set `max_allocated_storage = null`



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la
- 🐛 **Issues**: [GitHub Issues](https://github.com/gocloudLa/issues)

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 