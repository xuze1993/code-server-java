# code-server-jdk

jdk11 & python3.7

相比codesever v1现在终端无法粘贴，还未修复，可以在chrome浏览器使用 `Ctrl+Shift+V` 粘贴


`docker run -itd -p 9000:9000 -e -e CODER_PASSWORD=coder --restart=always -v code-cloud:/home/coder/projects  wixr7yss.mirror.aliyuncs.com/comm/code-server:latest`

<br/>

使用绝对路径挂载处理权限为comm:user
