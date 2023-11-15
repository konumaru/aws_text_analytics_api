FROM public.ecr.aws/lambda/python:3.10

COPY requirements.txt ./
COPY app.py ${LAMBDA_TASK_ROOT}

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

CMD [ "app.handler" ]
