#!/bin/bash
eval "$(conda shell.bash hook)"
conda activate fastapi
./main.sh local
