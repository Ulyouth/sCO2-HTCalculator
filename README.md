# sCO2-HTCalculator
A Heat Transfer Calculator for Supercritical CO2

# Motivation
* Difficulty of modelling the heat transfer of fluids in supercritical state
* Standard eqs used for fluids with constant properties cannot be applied for supercritical fluids

# Procedure
* Split the heat transfer domain in nodes (meshing)
* For each node, iterate the value of the heat transfer coefficient (qw), under the assumption that Tin ≈ Tout
* With the iterated qw values, calculate the outlet bulk temperature of the domain
* Repeat the process until the desired value is reached
* Plot the results as contours

# Limitations
* The equations used are only valid for very restricted conditions
* qw convergence criterium (Tin ≈ Tout), using the ΔT of the previous channel would be a better estimation for qw
* Only 2D domains are currently supported

# Credits
* Institute of Nuclear Technology & Energy Systems (IKE) for providing the sCO2 heat transfer eqs
