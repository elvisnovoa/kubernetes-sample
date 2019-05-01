resource "aws_iam_role" "eks_cluster_node_iam_role" {
  name = "eks-cluster-node-iam-role"

  assume_role_policy = <<POLICY
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
POLICY
}

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

resource "aws_iam_role_policy_attachment" "eks_cluster_node_DescribePolicy" {
  policy_arn = "${aws_iam_policy.describe_policy.arn}"
  role       = "${aws_iam_role.eks_cluster_node_iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks_cluster_node_iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks_cluster_node_iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks_cluster_node_iam_role.name}"
}

resource "aws_iam_instance_profile" "eks_cluster_node_instance_profile" {
  name = "eks-cluster-node-instance-profile"
  role = "${aws_iam_role.eks_cluster_node_iam_role.name}"
}