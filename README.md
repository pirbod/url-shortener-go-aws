# URL Shortener in Go on AWS (Terraform + ECS + DynamoDB)

    A secure, scalable, containerized URL shortening service built in Go.  
    This repo includes fully automated infrastructure via Terraform and GitHub Actions, deployed to AWS using ECS Fargate, DynamoDB, ALB, and WAF.


        `POST /shorten?url=...` → returns a short URL (API-key protected)
        `GET /{code}` → redirects to the original long URL
        DynamoDB as a persistence layer
        AWS ECS Fargate + ALB + WAF for secure, scalable hosting
        GitHub Actions CI/CD for both app and infrastructure
        Modular, multi-environment Terraform setup (`dev`, `prod`)

## Walkthough

    Clone the repo:

        git clone https://github.com/yourorg/url-shortener-go-aws.git
        cd url-shortener-go-aws

    Deploy infrastructure (dev):

        cd infra/env/dev
        terraform init
        terraform apply -auto-approve

    This provisions:

        VPC, subnets, routing

            ALB + WAF

            ECS cluster

            DynamoDB

            IAM roles

    Deploy app (via GitHub Actions)
        
        git commit -am "feat: initial app version"
        git push origin main


    This triggers:

            Docker image build & push to ECR

            ECS service update via ecs-task-def.json



## Local Testing

    Run the app with mock env:

	    cd app
	    go run main.go

    Set env vars (in .env or shell):
	
	    export API_KEY=test123
	    export BASE_URL=http://localhost:8080
	    export DYNAMODB_TABLE=dev-url-mapping

    Use curl to shorten a URL:

	    curl -X POST "http://localhost:8080/shorten?url=https://example.com" \
  	    -H "X-API-Key: test123"


    Expected Response:

	    {"short_url":"http://localhost:8080/2f"}


## Remote Testing (Deployed App)

    Find your deployed public endpoint (ALB DNS or custom domain):
	
	    # Terraform output OR AWS Console
	    https://dev-url-shortener-alb-xxxxx.elb.amazonaws.com

    Send the shorten request:

	    curl -X POST "https://<your-alb>/shorten?url=https://example.com" \
  	    -H "X-API-Key: dev-api-key"



## Security & Observability

    API Security: /shorten is protected via X-API-Key

         IAM:

             ECS Execution Role → pull images, write logs

             ECS Task Role → scoped to GetItem, PutItem on DynamoDB

         WAF: AWSManagedRulesCommonRuleSet filters common web exploits

        CloudWatch Logs: Application logs and ALB access logs


## CI/CD

     GitHub Actions

        deploy-infra.yml:
   	    Auto applies Terraform changes on infra/** push

    	deploy-app.yml:
   	    Builds Docker image, pushes to ECR, updates ECS service on app/** push

    All secrets (AWS_ROLE_ARN, ECR_REPO, etc.) configured via GitHub Secrets.




















