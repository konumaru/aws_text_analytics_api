FROM public.ecr.aws/lambda/python:3.10

# Copy requirements.txt
COPY requirements.txt ./
COPY data ${LAMBDA_TASK_ROOT}/data
COPY tokenizers ${LAMBDA_TASK_ROOT}/tokenizers
COPY lib ${LAMBDA_TASK_ROOT}/lib

# Copy function code
COPY app.py ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "app.handler" ]
