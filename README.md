fork link -> https://github.com/naqoda/docker-centos-apache-php

※셋팅 방법※

1) https://www.docker.com/ 에서 OS에 맞는 docker 를 다운받아 설치

2) 윈도우OS 의 경우 설치가 완료 되운 우측 하단 docker 아이콘에서 마우스 오른쪽 누른 후 
컨테이너가 Linux 인지 확인 후 아닐경우 스위치 클릭

3) setting 에 들어가서 Shared Drives -> 프로젝트 폴더 있는 드라이브 접근 허용 체크

4) CMD창에 접속하여 docker -v 를 눌러서 버전이 뜨는지 확인되면 정상 설치 완료

5) 아래의 커맨드를 순서대로 수행 

!!! 주의 !!! 
C:/Users/hsg37/IdeaProjects 이부분은 자신의 프로젝트 폴더의 경로로 변경 후 실행해야됨

Dockerfile_ 뒤에 php7 과 php56 은 각 PHP버전 입니다.
원하는 버전의 파일을 복사하여 _php{숫자}를 지우고 Dockerfile 만으로 저장 후 아래 스크립트를 실행하세요.

#빌드
docker build -t "local-dev" .

#실행
docker run --name local-dev-php -p 80:80 -d -v C:/Users/hsg37/IdeaProjects:/var/www/app -v C:/Users/hsg37/IdeaProjects/local-dev/etc/httpd/run/vhost.conf:/etc/httpd/conf.d/vhost.conf local-dev:latest

#bash 접속 방법
docker run -it local-dev:latest /bin/bash

6) 만약 etc/httpd/run/vhost.conf가 변경 되었을 시 아래 커맨드 실행 
docker restart local-dev-php 
