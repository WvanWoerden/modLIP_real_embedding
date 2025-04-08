FROM sagemath/sagemath:10.5

USER root
RUN apt-get update && \
    apt-get install -y git && \
    # Clean up apt cache to reduce final image size
    rm -rf /var/lib/apt/lists/*

USER sage
WORKDIR /sage

RUN git clone https://github.com/WvanWoerden/modLIP_real_embedding.git /sage/

# not sure why this is needed but otherwise sage can't find python
RUN echo 'export PATH="/home/sage/sage/local/var/lib/sage/venv-python3.12.5/bin:$PATH"' >> ~/.bashrc

CMD ["bash"]