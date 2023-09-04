# MATLAB_ICP

The scripts in this repository were used to perform the comparison experiments between different ICP error metrics.

They can also be used to evaluate ICP registration on other datasets and with different hyperparameters and graphically plot the results.

To evaluate ICP registration on a specific dataset with a specific set of hyperparameters:
1. Place your dataset in the “dataset” directory.
2. Define your experiments in “scripts/evaluateICPForSingleRegistration.m”
3. Use the existing templates in the “scripts” directory to define your registration trial on your dataset.
4. Use the “results/consolidateResult.m” to graphically plot the results.
