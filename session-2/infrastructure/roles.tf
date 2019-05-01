# Roles for Cluster and Nodes
resource "aws_iam_role" "role_eks_cluster" {
  name = "eks-service-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.role_eks_cluster.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.role_eks_cluster.name}"
}

resource "aws_iam_role" "role_eks_worker_node" {
  name = "eks-worker-node-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// Additional required policy
resource "aws_iam_policy" "describe_policy" {
  name = "eks-node-describe-policy"
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "ec2:Describe*"
           ],
           "Resource": "*"
       }
   ]
}

EOF
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_describe_policy" {
  policy_arn = "${aws_iam_policy.describe_policy.arn}"
  role       = "${aws_iam_role.role_eks_worker_node.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.role_eks_worker_node.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.role_eks_worker_node.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.role_eks_worker_node.name}"
}

resource "aws_iam_instance_profile" "eks_worker_node_instance_profile" {
  name = "eks-worker-node-instance-profile"
  role = "${aws_iam_role.role_eks_worker_node.name}"
}