# jenkin-pipeline-project



Create 3 EC2 instance
1 for jenkin
2 for Ansible
3 for Webaap

-----> install jenkins on jenkin server
-----> install docker on Ansible & Webapp server
-----> install ansible on  Ansible server 



-----> make SSH connection from jenkin-server to ansible-server
  Go to 
  vi /etc/ssh/sshd_config

change the values
PermitRootLogin yes

PasswordAuthentication yes

save 
---------> Restart SSHD
systemctl restart sshd

----> make SSH connection from ANSIBLE-server to WEBAAP-server
  Go to 
  vi /etc/ssh/sshd_config

change the values
PermitRootLogin yes

PasswordAuthentication yes

save 
---------> Restart SSHD
systemctl restart sshd


Do same with webaap-server
  Go to 
  vi /etc/ssh/sshd_config

change the values
PermitRootLogin yes

PasswordAuthentication yes

save 
---------> Restart SSHD
systemctl restart sshd

save


----->  make ssh connection
ansible server 
ssh-keygen

copy key in webaap server for password less authentication
ssh-copy-id  root@privateIDwebaap-server

---------> Go to webaap-server
change root pass
passwd root

----------> Go to Ansible-server
ssh root@PrivateIPWebaap-server

exit


------> Go to jenkin Deshboard
git checkout
send code (Dockerfile+playbook) to ansible server over ssh

add plugin for ssh 
pulgin_name 'public over ssh' 

go to manage jenking 
configure system 
go to public over ssh 
-------> add ansible-server 
click on add
name = ansible 
hostname = privateIPansible-server 
username = root

click on advance 
check use password authentication
type password 
click on Test connection 

------> add webaapserver
click on add
name = webaapserver 
hostname = privateIPwebaapserver
username = root

click on advance 
check use password authentication
type password 
click on Test connection

------> add jenkin
click on add
name = jenkin 
hostname = privateIPjenkin-server 
username = root

click on advance 
check use password authentication
type password 
click on Test connection

------> Create new item
 
select free-style
click  source code managment 
click on git
 add url 
 https://github.com/zabirao/devops-project-02.git
 add branch name 
save

build

go to ansible server 
cd /var/lib/jenkin/workspace/


------> send file from jenkin-server to ansible-server
go to project 
click on configure

click on Build 
select send file or execute  commands over SSH
---> SSH server

---->select jenkin-server
clcik advanced
check Verbose output in console

---> go to Exec command
rsync -avh /var/lib/jenkins/workspace/bitcypo/* root@privateIPansibleserver:/opt/

save apply
build

------->Go to ansible-server and check file in /opt/
cd /opt/
ls

-------> Now ansible server build image with dockerfile and push to docker hub

go to project in jenkin-server
go to configure
go to add build step
click send file or execute  commands over SSH

---> select ansible-server
---> go to Exec command
cd /opt/
docker image build -t $JOB_NAME:v1.$BUILD_ID .
docker image tag $JOB_NAME:v1.$BUILD_ID raoshahzaib/$JOB_NAME:v1.$BUILD_ID
docker image tag $JOB_NAME:v1.$BUILD_ID raoshahzaib/$JOB_NAME:latest

docker image push raoshahzaib/$JOB_NAME:v1.$BUILD_ID
docker image push raoshahzaib/$JOB_NAME:latest


docker rmi $JOB_NAME:v1.$BUILD_ID raoshahzaib/$JOB_NAME:v1.$BUILD_ID raoshahzaib/$JOB_NAME:latest

save apply 
build

----> Go and check docker repo & ansible server docker images

----> Now our Ansible-server run playbook  to depoloy our webaap 
----> Go to Ansible-server
vi /etc/ansible/hosts

goto [webaap servers]
type your groups 
[webaap]
webaapserverPrivateIP
save

now write our playbook 
vi webaap.yml
- hosts: all 
  tasks:
   - name : create new container
     shell: docker run -itd --name cryptoweb -p 9000:80 raoshahzaib/bitcypo


save 

Go to Jenkin server 
go to add build step
click send file or execute  commands over SSH
---->select jenkin-server
select adnave  verbose output 
---> go to Exec command

ansible-playbook /opt/webaap.yml

save apply 


now edite your bitcypo.yml file
- hosts: all
  tasks:
   - name: stop container
     shell: docker container stop webaap
   - name: remove container
     shell: docker container rm webaap
   - name: remove docker image
     shell: docker image rmi raoshahzaib/webaap
   - name: create new container
     shell: docker container run -itd --name webaap -p 9000:80 raoshahzaib/webaap
