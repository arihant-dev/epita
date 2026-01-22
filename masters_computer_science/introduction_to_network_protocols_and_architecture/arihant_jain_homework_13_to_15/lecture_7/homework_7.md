# Homework 7: Network Protocols and Architecture

## Exercise 14a

### Solution to Exercise 14a

Please refer to the attached file labelled "Arihant_Jain_Ex-7-13.pkt" for the detailed implementation of the exercise.

## Exercise 14b

### Solution to Exercise 14b

--> Dig

dig epita.net

    ``` bash
    ➜  nvim git:(master) ✗ dig epita.net
    ; <<>> DiG 9.10.6 <<>> epita.net
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 37711
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 512
    ;; QUESTION SECTION:
    ;epita.net.			IN	A

    ;; ANSWER SECTION:
    epita.net.		60	IN	A	91.243.117.174

    ;; Query time: 25 msec
    ;; SERVER: 8.8.8.8#53(8.8.8.8)
    ;; WHEN: Fri Jan 09 16:36:25 CET 2026
    ;; MSG SIZE  rcvd: 54
    ```

--> Dig with specific DNS server

dig @1.1.1.1 epita.net

    ``` bash
    ➜  nvim git:(master) ✗ dig @1.1.1.1 epita.net

    ; <<>> DiG 9.10.6 <<>> @1.1.1.1 epita.net
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 883
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 1232
    ; OPT=15: 00 12 ("..")
    ;; QUESTION SECTION:
    ;epita.net.			IN	A

    ;; ANSWER SECTION:
    epita.net.		60	IN	A	91.243.117.174

    ;; Query time: 10 msec
    ;; SERVER: 1.1.1.1#53(1.1.1.1)
    ;; WHEN: Fri Jan 09 16:37:49 CET 2026
    ;; MSG SIZE  rcvd: 60
    ```

--> Dig MX record

dig MX epita.net

    ``` bash
    ➜  nvim git:(master) ✗ dig MX epita.net

    ; <<>> DiG 9.10.6 <<>> MX epita.net
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 42212
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 512
    ;; QUESTION SECTION:
    ;epita.net.			IN	MX

    ;; ANSWER SECTION:
    epita.net.		3600	IN	MX	0 epita-net.mail.protection.outlook.com.

    ;; Query time: 21 msec
    ;; SERVER: 8.8.8.8#53(8.8.8.8)
    ;; WHEN: Fri Jan 09 16:38:26 CET 2026
    ;; MSG SIZE  rcvd: 91
    ```

--> nslookup

nslookup epita.net

    ``` bash 
    ➜  nvim git:(master) ✗ nslookup epita.net
    Server:		8.8.8.8
    Address:	8.8.8.8#53

    Non-authoritative answer:
    Name:	epita.net
    Address: 91.243.117.174
    ```

--> nslookup with specific DNS server

nslookup epita.net 1.1.1.1

    ``` bash
    ➜  nvim git:(master) ✗ nslookup epita.net 1.1.1.1
    Server:		1.1.1.1
    Address:	1.1.1.1#53

    Non-authoritative answer:
    Name:	epita.net
    Address: 91.243.117.174   
    ``` 

--> nslookup with debug

nslookup -debug epita.net

    ``` bash
    ➜  nvim git:(master) ✗ nslookup -debug epita.net        
    Server:		8.8.8.8
    Address:	8.8.8.8#53

    ------------
        QUESTIONS:
        epita.net, type = A, class = IN
        ANSWERS:
        ->  epita.net
        internet address = 91.243.117.174
        ttl = 60
        AUTHORITY RECORDS:
        ADDITIONAL RECORDS:
    ------------
    Non-authoritative answer:
    Name:	epita.net
    Address: 91.243.117.174
    ``` 

--> host

host epita.net

    ``` bash
    ➜  nvim git:(master) ✗ host epita.net
    epita.net has address 91.243.117.174
    epita.net mail is handled by 0 epita-net.mail.protection.outlook.com.
    ```