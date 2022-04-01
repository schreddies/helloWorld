FROM ubuntu:latest

RUN apt update 
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt install openssh-server sudo sudo gcc libpcre3-dev zlib1g-dev libluajit-5.1-dev libpcap-dev openssl libssl-dev libnghttp2-dev libdumbnet-dev bison flex libdnet autoconf libtool wget autoconf libtool make nano -y

RUN mkdir ~/snort_src && cd ~/snort_src

RUN wget https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz
RUN tar -xvzf daq-2.0.7.tar.gz
RUN cd daq-2.0.7 && autoreconf -f -i && ./configure --disable-dependency-tracking && make && sudo make install
RUN cd ~/snort_src && wget https://www.snort.org/downloads/snort/snort-2.9.19.tar.gz && tar -xvzf snort-2.9.19.tar.gz && cd snort-2.9.19 && ./configure --enable-sourcefire && make && sudo make install
RUN sudo ldconfig && sudo ln -s /usr/local/bin/snort /usr/sbin/snort
RUN sudo groupadd snort && sudo useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort
RUN sudo mkdir -p /etc/snort/rules && sudo mkdir /var/log/snort && sudo mkdir /usr/local/lib/snort_dynamicrules
RUN sudo chmod -R 5775 /etc/snort && sudo chmod -R 5775 /var/log/snort && sudo chmod -R 5775 /usr/local/lib/snort_dynamicrules && sudo chown -R snort:snort /etc/snort && sudo chown -R snort:snort /var/log/snort && sudo chown -R snort:snort /usr/local/lib/snort_dynamicrules
RUN sudo touch /etc/snort/rules/white_list.rules && sudo touch /etc/snort/rules/black_list.rules && sudo touch /etc/snort/rules/local.rules
RUN sudo cp ~/snort_src/snort-2.9.19/etc/*.conf* /etc/snort && sudo cp ~/snort_src/snort-2.9.19/etc/*.map /etc/snort
RUN wget https://www.snort.org/rules/community -O ~/community.tar.gz && sudo tar -xvf ~/community.tar.gz -C ~/ && sudo cp ~/community-rules/* /etc/snort/rules
RUN sudo sed -i 's/include $RULE_PATH/#include $RULE_PATH/' /etc/snort/snort.conf
RUN apt moo
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 test 

RUN  echo 'test:test' | chpasswd

RUN service ssh start

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]
