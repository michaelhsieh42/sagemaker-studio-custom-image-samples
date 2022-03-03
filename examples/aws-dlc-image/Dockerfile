FROM 763104351884.dkr.ecr.us-east-1.amazonaws.com/huggingface-pytorch-training:1.9.1-transformers4.12.3-gpu-py38-cu111-ubuntu20.04

# Installing ipykernel for notebook kernel
RUN pip install ipykernel && \
    python -m ipykernel install --sys-prefix
    
# Installing additional pkgs needed (following libraries are just examples)
RUN pip install ipywidgets 
RUN pip install rouge-score==0.0.4 nltk==3.6.7 sacrebleu==2.0.0