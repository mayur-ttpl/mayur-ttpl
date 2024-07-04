Overview
 Setup the agent for Jenkins master using JNLP method 
Prerequisites
Need to have ec2 server setup for Jenkins agent with linux os 

 Execution
Update the agent  machine and install java version 11 on jenkins  agent ec2 
$ sudo  - i
$ sudo apt update
$ sudo apt install openjdk-11-jre 

On Jenkins master server console 
Go to Jenkins-> configure global security -> Agents -> select RANDOM -> apply & save


Go to Jenkins ->Manage Jenkins-> Manage node and Clouds -> click on New Node 



Provide node name as per your custom configuration (here I used node1) and check it as a permanent agent. 
In the next page provide Number of executer as 1 , Remote root directory as ‘/root/Jenkins ‘  , Also specify the Usage as per your requirement , labels etc  and select the launch method as launch agent by connecting it to the controller - > apply and save.
Please refer below screenshot 




Click on node / agent which was created by in previous step , there we can see the command like this use the commands located in Run from agent command line 

#execute the generated commands on agent server which we configure or created for Jenkins agent 


# run the second command using nohup to run in background  
 Note :- don’t use ctrl + c after running below command to avoid agent configuration failure instead of close the agent server windows and again login if you want . 





Testing
We can able to the Agent is connected in agent section 





