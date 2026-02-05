FROM python:3.12

ENV INSTALL_PATH /requestssimulators
RUN mkdir -p ${INSTALL_PATH}
WORKDIR ${INSTALL_PATH}

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8007 8008 8009
