FROM codercom/code-server:v2

## auth is of no use in v2
## docker run -itd -p 8443:8443 -e PASSWORD='yourpassword' -v "${PWD}:/home/coder/project" comm/code-server --allow-http

# Update to zsh shell
RUN sudo apt-get install zsh -y
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

# Other stuff
USER coder
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /home/coder/.oh-my-zsh/plugins/zsh-autosuggestions
RUN echo "source ~/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /home/coder/.zshrc


USER root
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils openjdk-8-jre openjdk-8-jdk maven 2>&1 \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME  /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH  $JAVA_HOME/bin:$PATH


COPY User /home/coder/.local/share/code-server/User
RUN chown -R coder:coder /home/coder/.local/share/code-server/User
RUN chmod o+w /home

USER coder
ENTRYPOINT ["dumb-init", "code-server"]
