import boto3
region = 'us-east-1'
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    print(event)
    instance_id = [event['detail']['instance-id']]
    ec2.start_instances(InstanceIds=instance_id)
    print('started your instances: ' + str(instances))