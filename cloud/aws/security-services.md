AWS shield
Work on L3/L4 layer of OSI[network and transport layer]
AWS Shield is a managed Distributed Denial of Service (DDoS) protection service that safeguards applications running on AWS against DDoS attacks
AWS Shield Standard is automatically enabled on all AWS resources at no additional cost by default
Let's say you have a web application hosted on Amazon EC2 instances and exposed to the internet through an Elastic Load Balancer (ELB). Without protection, your application is vulnerable to DDoS attacks, which can flood your infrastructure with an overwhelming amount of traffic, leading to service disruptions and downtime, to avoid this type issue use shield
Based incoming traffic pattern it will stop DDos traffic. [based on pattern of traffic it knows about DDoS]
AWS WAF
Work at layer 7 [application layer]
It check incoming traffic original ip, http header, query string, URL Path etc. [refer waf docs from same folder]
Managed service that helps protect your web applications from common web exploits that could affect application availability, compromise security, or consume excessive resources. It allows you to create rules to filter web traffic based on conditions that you define.
Guardduty
It keep analyzing logs [vpc flowlogs, cloudwatch logs, cloudtrail logs etc] to see any suspicious.
It uses AI/ML & report the any suspicious activity happen at account level.
Inspector
Inspector checks application running in ec2 for any security vulnerability , it operate inside ec2 , not outside
Amazon Inspector automatically discovers and scans running Amazon EC2 instances, container images in Amazon Elastic Container Registry (Amazon ECR), and AWS Lambda functions for known software vulnerabilities and unintended network exposure. 

