![チャート](chart.png)

ruby 3.1

rails 7.0.4

mysql 5.7

- RailsとNginxを手動でECRに保存

  .github/workflows/Rails.yml : RailsをECRに保存

  .github/workflows/Nginx.yml : NginxをECRに保存

- deploy/にあるdocker-compose.ymlをEC2におくファイル

  .github/workflows/S3.yml name: copy local to s3

- S3に置いたdocker-compose.ymlをEC2にコピー

  .github/workflows/S3.yml name: copy s3 to ec2

- EC2からECRに保存したdockerimageをpull

  .github/workflows/EC2.yml

  主要コマンド pull, migrate:reset, seed:replant, up -d

Railsをpumaで起動、サーバーはnginx。

パス

http://micro-alb-484569792.ap-northeast-1.elb.amazonaws.com/

http://micro-alb-484569792.ap-northeast-1.elb.amazonaws.com/test/1

http://micro-alb-484569792.ap-northeast-1.elb.amazonaws.com/test/2

http://micro-alb-484569792.ap-northeast-1.elb.amazonaws.com/test/3

http://micro-alb-484569792.ap-northeast-1.elb.amazonaws.com/test/4

pumaの設定

config/puma.rb

nginxの設定

nginx/

EC2におくdocker-compose.yml

deploy/docker-compose.yml

ssm
```
aws ssm start-session --target i-0278a0585c410c6d2
```

ログ
```
root-web-1    | Puma starting in single mode...
root-web-1    | * Puma version: 5.6.5 (ruby 3.1.3-p185) ("Birdie's Version")
root-web-1    | *  Min threads: 5
root-web-1    | *  Max threads: 5
root-web-1    | *  Environment: development
root-web-1    | *          PID: 1
root-web-1    | * Listening on http://0.0.0.0:3000
root-web-1    | * Listening on unix:///app/tmp/sockets/puma.sock
root-web-1    | Use Ctrl-C to stop
root-nginx-1  | 10.0.20.102 - - [27/Mar/2023:09:02:45 +0000] "GET / HTTP/1.1" 200 2252 "-" "ELB-HealthChecker/2.0"
root-nginx-1  | 10.0.4.117 - - [27/Mar/2023:09:02:45 +0000] "GET / HTTP/1.1" 200 2252 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36"
root-nginx-1  | 10.0.4.117 - - [27/Mar/2023:09:02:49 +0000] "GET /test/1 HTTP/1.1" 200 2258 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36"
root-nginx-1  | 10.0.4.117 - - [27/Mar/2023:09:02:51 +0000] "GET / HTTP/1.1" 200 2252 "-" "ELB-HealthChecker/2.0"
```

pumaの中身
```rb
# Workers are forked web server processes. If using threads and workers together
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
plugin :tmp_restart

app_root = File.expand_path("../..", __FILE__)
bind "unix://#{app_root}/tmp/sockets/puma.sock"

stdout_redirect "#{app_root}/log/puma.stdout.log", "#{app_root}/log/puma.stderr.log", true
```

nginxの中身

Dockerfile
```Dockerfile
FROM nginx:1.15.8

# インクルード用のディレクトリ内を削除
RUN rm -f /etc/nginx/conf.d/*

# Nginxの設定ファイルをコンテナにコピー
ADD nginx.conf /etc/nginx/conf.d/webapp.conf

# ビルド完了後にNginxを起動
CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
```

nginx.conf
```conf
# プロキシ先の指定
# Nginxが受け取ったリクエストをバックエンドのpumaに送信
upstream app {
  # ソケット通信したいのでpuma.sockを指定
  server unix:///app/tmp/sockets/puma.sock;
}

server {
  listen 80;
  # ドメインもしくはIPを指定
  server_name example.com [or 192.168.xx.xx [or localhost]];

  access_log /var/log/nginx/access.log;
  error_log  /var/log/nginx/error.log;

  # ドキュメントルートの指定
  root /app/public;

  client_max_body_size 100m;
  error_page 404             /404.html;
  error_page 505 502 503 504 /500.html;
  try_files  $uri/index.html $uri @app;
  keepalive_timeout 5;

  # リバースプロキシ関連の設定
  location @app {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_pass http://app;
  }
}
```
