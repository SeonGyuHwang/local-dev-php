#info
~~~
OS: CentOS7 
SERVER: Apache 2.2
LANG: PHP 7.1
DB: MySQL, Oci8-2.2
~~~

#셋팅
~~~
1) https://www.docker.com/ 에서 OS에 맞는 docker 를 다운받아 설치

2) Setting -> Resources -> Shared Drives -> workspace 폴더 있는 드라이브 접근 허용 체크

3) CMD창에 접속하여 docker -v 를 눌러서 버전이 뜨는지 확인되면 정상 설치 완료

4) ./etc/httpd/vhost.conf에서 <VirtualHost /> 를 셋팅해준다. 
~~~

#빌드 & 실행
~~~
기본 workspace폴더 경로는 /D/workspace 입니다
위 경로와 틀릴경우 docker-compose.yml 에서 volumes부분의 경로를 수정해주세요

docker-compose up -d

※ -d 는 백그라운드 돌리는 옵션
※ OS별 hosts 파일에 다음과 같이 추가해주세요 
127.0.0.1 my.project.co.kr
~~~

#vhost.conf가 변경 되었을 시 아래 커맨드 실행
~~~
docker restart local-dev-php 

또는

Docker 대쉬보드에서 해당 컨테이너 Restart 아이콘 클릭
~~~

#bash 접속 방법
~~~
docker run -it hsg377/php71:latest /bin/bash

또는
 
Docker 대쉬보드에서 해당 컨테이너 >_ 아이콘 클릭
~~~
