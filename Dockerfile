From codercom/code-server:latest

ENV CODER_PASSWORD="coder"

# Update to zsh shell
RUN sudo apt-get update && sudo apt-get install  wget zsh -y
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Setup python development
RUN sudo apt-get update
RUN sudo apt-get install python3.7-dev python3-pip nano inetutils-ping -y
RUN python3.7 -m pip install pip
RUN python3.7 -m pip install wheel
RUN python3.7 -m pip install -U pylint --user

# Setup go development
RUN wget https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz -O /tmp/go.tar.gz
RUN sudo tar -C /usr/local -xzf /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"
RUN rm -rf /tmp.go.tar.gz

# Install extensions
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension eamodio.gitlens
RUN code-server --install-extension ms-vscode.go
RUN code-server --install-extension ms-ceintl.vscode-language-pack-zh-hans
RUN code-server --install-extension vscjava.vscode-java-pack
RUN code-server --install-extension formulahendry.code-runner

# Other stuff
USER coder
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /home/coder/.oh-my-zsh/plugins/zsh-autosuggestions
RUN echo "source ~/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /home/coder/.zshrc


USER root
RUN apt-get update \
#can no longer be found in the repositories as Oracle removed support for it earlier this year for those not paying for a commercial license
    && apt-get -y install --no-install-recommends apt-utils default-jdk maven 2>&1 \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

#ENV JAVA_HOME  /usr/lib/jvm/java-8-openjdk-amd64
ENV JAVA_HOME  /usr/lib/jvm/java-11-openjdk-amd64
ENV PATH  $JAVA_HOME/bin:$PATH

#add script for auth and init personal settings
COPY exec /opt
COPY entrypoint /home/coder
COPY User /home/coder/.local/share/code-server/User

RUN     cp /usr/bin/code-server   /usr/local/bin/code-server  \
    &&  cp /usr/bin/python3  /usr/bin/python  \
    &&  echo "alias ll='ls -l'" >> /etc/profile  &&  echo "alias ll='ls -l'" >> /home/coder/.bashrc \
    &&  chown -R coder:coder /home/coder/.local/share/code-server/User && chmod o+w /home

USER coder
RUN mkdir -p /home/coder/projects
EXPOSE 9000
ENTRYPOINT ["/home/coder/entrypoint"]
CMD ["/opt/exec"]
