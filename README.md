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
| <a href="https://github.com/terraform-aws-modules/terraform-aws-eventbridge" target="_blank">terraform-aws-modules/eventbridge/aws</a> | 4.2.1 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-lambda" target="_blank">terraform-aws-modules/lambda/aws</a> | 8.1.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-rds" target="_blank">terraform-aws-modules/rds/aws</a> | 6.13.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-s3-bucket" target="_blank">terraform-aws-modules/s3-bucket/aws</a> | 5.7.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-security-group" target="_blank">terraform-aws-modules/security-group/aws</a> | 5.3.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-ssm-parameter" target="_blank">terraform-aws-modules/ssm-parameter/aws</a> | 1.1.2 |



## 🚀 Quick Start
```hcl
rds_parameters = {
  "mariadb-00" = {

    ## Definitions for the database engine
    engine               = "mariadb"
    engine_version       = "11.4"
    major_engine_version = "11.4"
    family               = "mariadb11.4"
    instance_class       = "db.t3.micro"

    deletion_protection = false
    apply_immediately   = true
    skip_final_snapshot = true

    ## Definitions of subnets where the engine will be deployed and accessed
    subnet_ids          = data.aws_subnets.public.ids
    publicly_accessible = true

    ingress_with_cidr_blocks = [
      {
        rule        = "mysql-tcp"
        cidr_blocks = "0.0.0.0/0" # public IP range, adjust as needed
      }
    ]

    dns_records = {
      "" = {
        zone_name    = local.zone_public
        private_zone = false
      }
    }

    ## Database engine parameters
    parameters = [
      {
        name  = "max_connections"
        value = "150"
      }
    ]

    ## Maintenance windows and backup configuration
    maintenance_window      = "Sun:04:00-Sun:06:00"
    backup_window           = "03:00-03:30"
    backup_retention_period = "7"
  }

  "mysql-00" = {

    ## Definitions for the database engine
    engine               = "mysql"
    engine_version       = "8.0.37"
    major_engine_version = "8.0"
    family               = "mysql8.0"
    instance_class       = "db.t3.micro"

    deletion_protection = false
    apply_immediately   = true
    skip_final_snapshot = true

    ## Definitions of subnets where the engine will be deployed and accessed
    subnet_ids          = data.aws_subnets.private.ids
    publicly_accessible = false

    ingress_with_cidr_blocks = [
      {
        rule        = "mysql-tcp"
        cidr_blocks = "0.0.0.0/0" # public IP range, adjust as needed
      }
    ]

    dns_records = {
      "" = {
        zone_name    = local.zone_private
        private_zone = true
      }
    }

    ## Maintenance windows and backup configuration
    maintenance_window      = "Sun:04:00-Sun:06:00"
    backup_window           = "03:00-03:30"
    backup_retention_period = "7"
  }

  "pgsql-00" = {

    ## Definitions for the database engine
    engine               = "postgres"
    engine_version       = "16"
    major_engine_version = "16"
    family               = "postgres16"
    instance_class       = "db.t3.micro"
    port                 = "5432"

    deletion_protection = false
    apply_immediately   = true
    skip_final_snapshot = true

    ## Definitions of subnets where the engine will be deployed and accessed
    subnet_ids          = data.aws_subnets.public.ids
    publicly_accessible = true

    ingress_with_cidr_blocks = [
      {
        rule        = "postgresql-tcp"
        cidr_blocks = "0.0.0.0/0" # public IP range, adjust as needed
      }
    ]

    dns_records = {
      "" = {
        zone_name    = local.zone_public
        private_zone = false
      }
    }

    ## Maintenance windows and backup configuration
    maintenance_window      = "Sun:04:00-Sun:06:00"
    backup_window           = "03:00-03:30"
    backup_retention_period = "7"
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
This module creates the necessary resources to generate an SQL dump and store it in an S3 bucket, along with cleanup scripts for the database. It also allows to specify which AWS account ARNs have access to the S3 bucket. <br/> It supports the database engines **MySQL**, **MariaDB**, and **PostgreSQL**.


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




## 📑 Inputs
| Name                                                   | Description                                                            | Type           | Default                                                  | Required |
| ------------------------------------------------------ | ---------------------------------------------------------------------- | -------------- | -------------------------------------------------------- | -------- |
| engine                                                 | Database engine                                                        | `string`       | `"mariadb"`                                              | no       |
| engine_version                                         | Desired engine version                                                 | `string`       | `"10.6.14"`                                              | no       |
| instance_class                                         | Resource size                                                          | `string`       | `"db.t3.micro"`                                          | no       |
| deletion_protection                                    | Resource deletion protection                                           | `bool`         | `true`                                                   | no       |
| publicly_accessible                                    | Enable internet access                                                 | `bool`         | `false`                                                  | no       |
| subnet_ids                                             | List of subnets on which the resource is deployed                      | `list`         | `[]`                                                     | no       |
| subnet_name                                            | Wildcard to find the subnets where to deploy engine and lambdas        | `string`       | `"${local.common_name_prefix}-private*"`                 | no       |
| ingress_with_cidr_blocks                               | Inbound rules for the resource                                         | `list`         | `[{ rule = "mysql-tcp", cidr_blocks = "172.1.0.0/16" }]` | no       |
| allocated_storage                                      | Minimum instance storage                                               | `number`       | `5`                                                      | no       |
| max_allocated_storage                                  | Maximum instance storage                                               | `number`       | `10`                                                     | no       |
| storage_type                                           | Storage type                                                           | `string`       | `null`                                                   | no       |
| maintenance_window                                     | Maintenance window schedule                                            | `string`       | `"Sun:04:00-Sun:06:00"`                                  | no       |
| backup_window                                          | Backup window schedule                                                 | `string`       | `null`                                                   | no       |
| backup_retention_period                                | Backup retention in days                                               | `number`       | `null`                                                   | no       |
| apply_immediately                                      | Apply immediately changes that may restart the engine                  | `bool`         | `false`                                                  | no       |
| performance_insights_enabled                           | Enable Performance Insights feature                                    | `bool`         | `false`                                                  | no       |
| performance_insights_retention_period                  | Performance Insights information retention                             | `number`       | `7`                                                      | no       |
| username                                               | The master username of the database                                    | `string`       | `root`                                                   | no       |
| password                                               | The master user password generated by the random password resource     | `string`       | `${random_password.this[each.key].result}`               | no       |
| manage_master_user_password                            | Automatically manage master user password rotation                     | `bool`         | `false`                                                  | no       |
| master_user_secret_kms_key_id                          | KMS key ID to encrypt the master user secret                           | `string`       | `null`                                                   | no       |
| manage_master_user_password_rotation                   | Enable automatic rotation of the master user password                  | `bool`         | `false`                                                  | no       |
| master_user_password_rotate_immediately                | Rotate master user password immediately                                | `bool`         | `null`                                                   | no       |
| master_user_password_rotation_automatically_after_days | Number of days after which the password is rotated automatically       | `number`       | `null`                                                   | no       |
| master_user_password_rotation_duration                 | Duration in days of the password validity after rotation               | `number`       | `null`                                                   | no       |
| master_user_password_rotation_schedule_expression      | Scheduling expression for rotation (example, cron)                     | `string`       | `null`                                                   | no       |
| create_db_subnet_group                                 | Indicates whether a subnet group should be created for the database    | `bool`         | `true`                                                   | no       |
| db_subnet_group_name                                   | Name of the subnet group for the database                              | `string`       | `${local.common_name}-${each.key}`                       | no       |
| db_subnet_group_use_name_prefix                        | Use a name prefix for the subnet group                                 | `bool`         | `false`                                                  | no       |
| db_subnet_group_description                            | Subnet group description                                               | `string`       | `null`                                                   | no       |
| db_subnet_group_tags                                   | Tags assigned to the subnet group                                      | `map`          | `{}`                                                     | no       |
| create_db_parameter_group                              | Indicates whether a parameter group should be created for the database | `bool`         | `true`                                                   | no       |
| parameter_group_name                                   | Name of the parameter group for the database                           | `string`       | `${local.common_name}-${each.key}`                       | no       |
| parameter_group_use_name_prefix                        | Use a name prefix for the parameter group                              | `bool`         | `false`                                                  | no       |
| family                                                 | Database family for the parameter group                                | `string`       | `mariadb10.6`                                            | no       |
| parameters                                             | List of parameter group parameters                                     | `list`         | `[]`                                                     | no       |
| parameter_group_description                            | Parameter group description                                            | `string`       | `null`                                                   | no       |
| db_parameter_group_tags                                | Tags assigned to the parameter group                                   | `map`          | `{}`                                                     | no       |
| create_db_option_group                                 | Indicates whether an option group should be created for the database   | `bool`         | `true`                                                   | no       |
| option_group_name                                      | Name of the option group for the database                              | `string`       | `${local.common_name}-${each.key}`                       | no       |
| option_group_use_name_prefix                           | Use a name prefix for the option group                                 | `bool`         | `false`                                                  | no       |
| major_engine_version                                   | Major engine version for the option group                              | `string`       | `10.6`                                                   | no       |
| options                                                | List of option group options                                           | `list`         | `[]`                                                     | no       |
| option_group_description                               | Option group description                                               | `string`       | `null`                                                   | no       |
| option_group_timeouts                                  | Timeouts for option group operations                                   | `map`          | `{}`                                                     | no       |
| db_option_group_tags                                   | Tags assigned to the option group                                      | `map`          | `{}`                                                     | no       |
| option_group_skip_destroy                              | Whether to prevent the option group from being destroyed               | `bool`         | `null`                                                   | no       |
| create_db_instance                                     | Indicates whether to create the database instance                      | `bool`         | `true`                                                   | no       |
| engine_lifecycle_support                               | Database engine lifecycle support                                      | `string`       | `null`                                                   | no       |
| instance_class                                         | Database instance class.                                               | `string`       | `db.t3.micro`                                            | no       |
| port                                                   | Port for database connection.                                          | `number`       | `3306`                                                   | no       |
| db_name                                                | Database name.                                                         | `string`       | `null`                                                   | no       |
| vpc_security_group_ids                                 | List of VPC security group IDs.                                        | `list(string)` | `[module.security_group_rds]`                            | no       |
| network_type                                           | Network type for the database.                                         | `string`       | `null`                                                   | no       |
| availability_zone                                      | Availability zone for the database.                                    | `string`       | `null`                                                   | no       |
| multi_az                                               | Enable multi-AZ for high availability.                                 | `bool`         | `false`                                                  | no       |
| kms_key_id                                             | KMS key ID for database encryption.                                    | `string`       | `null`                                                   | no       |
| ca_cert_identifier                                     | CA certificate identifier for the database.                            | `string`       | `null`                                                   | no       |
| publicly_accessible                                    | Indicates if the database is publicly accessible.                      | `bool`         | `false`                                                  | no       |
| deletion_protection                                    | Protection against database deletion.                                  | `bool`         | `true`                                                   | no       |
| timeouts                                               | Timeout settings for the database.                                     | `map`          | `{}`                                                     | no       |
| snapshot_identifier                                    | Snapshot identifier for database restore.                              | `string`       | `null`                                                   | no       |
| db_instance_tags                                       | Tags assigned to the database instance.                                | `map`          | `{}`                                                     | no       |
| custom_iam_instance_profile                            | Custom IAM instance profile.                                           | `string`       | `null`                                                   | no       |
| dedicated_log_volume                                   | Indicates if a dedicated volume should be created for database logs.   | `bool`         | `false`                                                  | no       |
| allocated_storage                                      | Allocated storage for the database.                                    | `number`       | `5`                                                      | no       |
| max_allocated_storage                                  | Maximum allocated storage for the database.                            | `number`       | `10`                                                     | no       |
| storage_type                                           | Storage type (gp2, io1, etc.).                                         | `string`       | `null`                                                   | no       |
| iops                                                   | Number of IOPS allocated for storage.                                  | `number`       | `null`                                                   | no       |
| storage_throughput                                     | Storage performance in MB/s.                                           | `number`       | `null`                                                   | no       |
| storage_encrypted                                      | Indicates if the storage is encrypted.                                 | `bool`         | `true`                                                   | no       |
| upgrade_storage_config                                 | Configuration for storage upgrade.                                     | `string`       | `null`                                                   | no       |
| iam_database_authentication_enabled                    | Enable IAM authentication for the database.                            | `bool`         | `false`                                                  | no       |
| domain                                                 | Domain to which the database is associated.                            | `string`       | `null`                                                   | no       |
| domain_auth_secret_arn                                 | ARN of the domain authentication secret.                               | `string`       | `null`                                                   | no       |
| domain_dns_ips                                         | DNS IPs associated with the domain.                                    | `list`         | `null`                                                   | no       |
| domain_fqdn                                            | FQDN (fully qualified domain name) of the domain.                      | `string`       | `null`                                                   | no       |
| domain_iam_role_name                                   | Name of the IAM role associated with the domain.                       | `string`       | `null`                                                   | no       |
| domain_ou                                              | Organizational unit (OU) of the domain.                                | `string`       | `null`                                                   | no       |
| delete_automated_backups                               | Indicates if automated backups should be deleted.                      | `bool`         | `true`                                                   | no       |
| restore_to_point_in_time                               | Restore to a specific point in time.                                   | `string`       | `null`                                                   | no       |
| final_snapshot_identifier_prefix                       | Prefix for the final snapshot identifier.                              | `string`       | `null`                                                   | no       |
| skip_final_snapshot                                    | Skip final snapshot creation on instance deletion.                     | `bool`         | `true`                                                   | no       |
| copy_tags_to_snapshot                                  | Copy tags to the snapshot when creating it.                            | `bool`         | `true`                                                   | no       |
| maintenance_window                                     | Maintenance window for the RDS instance.                               | `string`       | `"Sun:04:00-Sun:06:00"`                                  | no       |
| allow_major_version_upgrade                            | Allow major version upgrade of the database engine.                    | `bool`         | `false`                                                  | no       |
| auto_minor_version_upgrade                             | Automatic minor version upgrade.                                       | `bool`         | `true`                                                   | no       |
| apply_immediately                                      | Apply changes immediately, if possible.                                | `bool`         | `false`                                                  | no       |
| create_monitoring_role                                 | Create the monitoring role for RDS.                                    | `bool`         | `true`                                                   | no       |
| monitoring_role_arn                                    | ARN of the existing monitoring role.                                   | `string`       | `null`                                                   | no       |
| monitoring_role_name                                   | Name of the monitoring role.                                           | `string`       | `"${local.common_name}-rds-monitoring-${each.key}"`      | no       |
| monitoring_role_use_name_prefix                        | Use prefix for the monitoring role name.                               | `bool`         | `false`                                                  | no       |
| monitoring_role_description                            | Description of the monitoring role.                                    | `string`       | `null`                                                   | no       |
| monitoring_interval                                    | Monitoring interval in seconds.                                        | `number`       | `0`                                                      | no       |
| performance_insights_kms_key_id                        | KMS Key ID for Performance Insights.                                   | `string`       | `null`                                                   | no       |
| create_cloudwatch_log_group                            | Create log group in CloudWatch.                                        | `bool`         | `false`                                                  | no       |
| enabled_cloudwatch_logs_exports                        | Export logs to CloudWatch.                                             | `list`         | `[]`                                                     | no       |
| cloudwatch_log_group_retention_in_days                 | Log retention in CloudWatch (days).                                    | `number`       | `7`                                                      | no       |
| cloudwatch_log_group_kms_key_id                        | KMS Key ID for the log group in CloudWatch.                            | `string`       | `null`                                                   | no       |
| monitoring_role_permissions_boundary                   | Permission limit for the monitoring role.                              | `string`       | `null`                                                   | no       |
| cloudwatch_log_group_skip_destroy                      | Skip the destruction of the log group in CloudWatch.                   | `bool`         | `null`                                                   | no       |
| cloudwatch_log_group_class                             | Class of the log group in CloudWatch.                                  | `string`       | `null`                                                   | no       |
| license_model                                          | License model for databases.                                           | `string`       | `null`                                                   | no       |
| timezone                                               | Time zone for SQL Server databases.                                    | `string`       | `null`                                                   | no       |
| replicate_source_db                                    | Source instance name for replication.                                  | `string`       | `null`                                                   | no       |
| replica_mode                                           | Replica mode for the database instance.                                | `string`       | `null`                                                   | no       |
| character_set_name                                     | Name of the database character set.                                    | `string`       | `null`                                                   | no       |
| nchar_character_set_name                               | Name of the NCHAR character set of the database.                       | `string`       | `null`                                                   | no       |
| s3_import                                              | Data import configuration from S3 for MySQL.                           | `string`       | `null`                                                   | no       |
| db_instance_role_associations                          | Database instance role associations (e.g., IAM).                       | `map`          | `{}`                                                     | no       |
| tags                                                   | A map of tags to assign to resources.                                  | `map`          | `{}`                                                     | no       |







## ⚠️ Important Notes
- **🚨 Engine Restart:** Parameter changes won't restart the database automatically. Use `apply_immediately = true` to apply changes immediately.
- **⚠️ Public Access:** Control internet exposure of the instance with `publicly_accessible = true` or `false`.
- **ℹ️ Storage Growth:** Set `max_allocated_storage = 0` to allow unlimited storage growth.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 