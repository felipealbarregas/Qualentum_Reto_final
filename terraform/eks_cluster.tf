
module "eks_cluster_produccion" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"  

  cluster_name    = "produccion"

  vpc_id          = aws_vpc.my_vpc.id
  subnet_ids      = [aws_subnet.public_subnet_1a.id]

  eks_managed_node_groups = {
    app = {
      name                 = "app"
      instance_types       = ["t2.small"]
      min_size             = 1
      max_size             = 4
      desired_size         = 2

      scaling_config = {
        scale_down = {
          enabled          = true
          evaluation_periods = 3
          cooldown         = 300
          adjustment_type  = "ChangeInCapacity"
          min_adjustment_magnitude = 1
          type             = "cpu"
          value            = 20
        }
        scale_up = {
          enabled          = true
          cooldown         = 300
          adjustment_type  = "ChangeInCapacity"
          min_adjustment_step = 1
          type             = "ChangeInCapacity"
          value            = 1
        }
      }
    },
    database = {
      name                 = "database"
      instance_types       = ["t2.small"]
      min_size             = 1
      max_size             = 4
      desired_size         = 1

      scaling_config = {
        scale_down = {
          enabled          = true
          evaluation_periods = 3
          cooldown         = 300
          adjustment_type  = "ChangeInCapacity"
          min_adjustment_magnitude = 1
          type             = "cpu"
          value            = 20
        }
        scale_up = {
          enabled          = true
          cooldown         = 300
          adjustment_type  = "ChangeInCapacity"
          min_adjustment_step = 1
          type             = "ChangeInCapacity"
          value            = 1
        }
      }
    }
  }
}
