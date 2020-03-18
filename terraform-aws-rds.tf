#############################
# Mysql engine database creation
#############################

resource "aws_db_instance" "database" {
  identifier               = "rds-instance-name"    
  license_model     = "license-included"
  allocated_storage        = "20"
  storage_type             = "gp2"
  storage_encrypted        =  "true"
  kms_key_id               = "${aws_kms_key.a.arn}"
  iops                     = "0"
  engine                   = "sqlserver-se"
  engine_version           = "13.00.4466.4.v1"
  instance_class           = "db.r4.xlarge"
  username                 = "buildmaster"                  # Database username
  password                 = "dafaksnhryasop"               # Database password
  maintenance_window       = "sun:03:00-sun:03:30"          # maintenance period
  auto_minor_version_upgrade  = "true"                      # upgradation of engine_version
  allow_major_version_upgrade = "false"
  monitoring_interval      = "0"
  monitoring_role_arn      = ""
  multi_az                 = "false"
  backup_window            = "01:00-01:30"
  backup_retention_period  = "0"
  db_subnet_group_name     = "${aws_db_subnet_group.rds_subnet_group.id}"
  skip_final_snapshot      = "true"
  parameter_group_name     = "${aws_db_parameter_group.rds_parameter_group.name}"
  vpc_security_group_ids   = ["sg-035fc24d3431ec53e"]
  publicly_accessible      = "true"                          # publicly accessible or private
  lifecycle {
     ignore_changes        = "[vpc_security_group_ids, tags, username, password]"
  }

  tags {
         Name             = "Name_rds_db"
      }
}

##########################
# Creating of subnet group
##########################

resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "db-subnetgroup-t"
  subnet_ids  = ["subnet-0ed6c0843b5692123", "subnet-0064a0e0afbfa4920"]
}


##########################
# Creating of parameter group
###########################

resource "aws_db_parameter_group" "rds_parameter_group" {
  name = "db-parametergroup-t"
  family = "sqlserver-se-13.0"  
  tags {
    Name = "parameter_group_name"
  }
}



resource "aws_kms_key" "a" {
  description  = "KMS key for rds"
  #Alias = "aws/rds"
  tags {
    Name = "kms-keyname-t"
    Alias = "aws/rds"
  }
}

#################################
# Route 53 DNS hosted zone
#################################
data "aws_route53_zone" "selected" {
  name         = "example.com."
  private_zone = true
}



###################################
# DNS record creation
###################################

resource "aws_route53_record" "database-route" {
  zone_id = "${aws_route53_zone.selected.zone_id}"
  name = "database.test.com"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_db_instance.database.address}"]
}
