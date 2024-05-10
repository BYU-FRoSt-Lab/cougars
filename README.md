This repo contains the basic files and scripts necessary to set up a new Coug-UV in the BYU FRoSt lab's **Cooperative Underwater Group of Autonomous Robots (CoUGARs)**. 
After flashing a new RPi 5 with a version of Ubuntu (we've been using Server 24.04 LTS), simply log into it over ssh, clone this repository, and run "setup.sh".
You should then be able to spin up the latest Docker image as a container using "docker.sh", and add additional terminals in that container using "extra.sh".

If you're looking to do remote development on the Coug-UV, check out these repos instead: https://github.com/snelsondurrant/CougarsRPi.git, https://github.com/snelsondurrant/CougarsTeensy.git
