# File:    Makefile
# Author:  Rob Roos
# Purpose: 
#.PHONY: all
all: add_to_repo

# make defines a tab is required to start each recipe. All actions of every rule are identified by tabs. 
# If you prefer to prefix your recipes with a character other than tab, you can set the .RECIPEPREFIX variable to an alternate character.
# To check, I use the command cat -e -t -v makefile_name.
# It shows the presence of tabs with ^I and line endings with $. 
# Both are vital to ensure that dependencies end properly and tabs mark the action for the rules so that they are easily identifiable to the make utility.

###############################################
# Generic commands for PROD and NONPROD account
###############################################
ask:
	#Each command runs in its own subshell, so variables can't survive from one command to the next. Put them on the same line and they'll work:
	@read -p "Enter Module Name:" module; \
	echo  $$module;\
	module_dir="./modules/$$module";\
	echo $$module_dir/build

add_to_repo:
#Each command runs in its own subshell, so variables can't survive from one command to the next. Put them on the same line and they'll work:
	@read -p "Enter commit message:" commitmessage; \
	if [ -n  "$$commitmessage" ]; then\
		 echo 'this is my commit message $$commitmessage';\
		 echo "Adding files to staging area...";\
		 git add .;\
		 echo "commit files with commit message $$commitmessage ...";\
		 git commit -m"$$commitmessage";\
		 echo "push files to github";\
		 git push;\
	else\
		echo no commit message;\
	fi

zipupdate:
	# you need the zip command. IN WSL, issue first this command: sudo apt install zip
	zip -g PIR-lambda1.zip lambda_function.py

.PHONY: upload
upload:
	@echo "Starting  upload to lambda"
	aws lambda update-function-code --function-name  PIR-lambda1 --zip-file fileb://PIR-lambda1.zip  --region eu-central-1	
	@echo "Please also invoke make tst_uploadViaS3 or make uploadViaS3 so that the updated code is also in S3"


.PHONY: invoke
invoke:
	@echo "invoke lambda function"
	 aws lambda invoke --function-name PIR-lambda1 --region eu-central-1 PIR-lambda1.out 
	 cat PIR-lambda1.out 

 
#######################################
# Athlon International NONPROD commands
#######################################

tst_create_function:
	aws lambda  create-function --function-name PIR-lambda1 --runtime python3.9 \
	   --role arn:aws:iam::387603950885:role/PrivIdentityReportIamRole \
	   --description "get aws config info for Identity Reporting"  --region eu-central-1 \
	   --zip-file fileb://PIR-lambda1.zip --timeout 200  --handler lambda_function.lambda_handler \
	   --vpc-config SubnetIds=subnet-0e585d30599b97f52,subnet-059c74ca10d4213cf,SecurityGroupIds=sg-03579d4f64609551a
	#  SubnetA-Management, SubnetB-Management ,SG-Management

tst_uploadViaS3_and_update_function:
	@echo "Starting  upload to S3 Functions bucket"
	aws s3 cp PIR-lambda1.zip s3://awsfunctions3bucket-387603950885/AthlonInternational/reporting/privilegedusers/PIR-lambda1.zip
	aws lambda update-function-code --function-name  PIR-lambda1 --s3-bucket awsfunctions3bucket-387603950885 --s3-key AthlonInternational/reporting/privilegedusers/PIR-lambda1.zip  --region eu-central-1	
	

#######################################
# Athlon International PROD commands
#######################################

create_function:
	aws lambda  create-function --function-name PIR-lambda1 --runtime python3.9 \
	   --role arn:aws:iam::581759791094:role/PrivIdentityReportIamRole \
	   --description "get aws config info for Identity Reporting"  --region eu-central-1 \
	   --zip-file fileb://PIR-lambda1.zip --timeout 200  --handler lambda_function.lambda_handler \
	   --vpc-config SubnetIds=subnet-0ac617bb2fce499ac,subnet-011f029b83b72a5b6,SecurityGroupIds=sg-0aef3b75501493391
	#  SubnetA-Management, SubnetB-Management ,SG-Management

uploadViaS3_and_update_function:
	@echo "Starting  upload to S3 Functions bucket"
	aws s3 cp PIR-lambda1.zip s3://awsfunctions3bucket-581759791094/AthlonInternational/reporting/privilegedusers/PIR-lambda1.zip
	aws lambda update-function-code --function-name  PIR-lambda1 --s3-bucket awsfunctions3bucket-581759791094 --s3-key AthlonInternational/reporting/privilegedusers/PIR-lambda1.zip  --region eu-central-1	



