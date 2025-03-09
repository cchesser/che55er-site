from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB

with Diagram("services"):
    b_service = EC2("b")
    db = RDS("db") 
    ELB("a") >> b_service >> db
    b_service >> EC2("c") >> db