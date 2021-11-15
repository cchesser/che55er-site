# Diagnose Your Lethargic JVM


{{< youtube WIpN_U1nMAI >}}

If you are building Java Virtual Machine based services, a core measurement of your success is performance.  The act of measuring and analyzing how your code is performing becomes an essential activity in all phases of your development. This skill becomes even more critical once you are required to troubleshoot and evaluate your service in a unique production environment. Understanding what operations are consuming most of our CPU time, as well as, what areas of your code are wasting resources will greatly improve your ability to diagnose a sluggish JVM.

In this talk, we will explore the key tools for monitoring and measuring the JVM. An overview will be provided on core concepts involving thread state and memory management operations. Examples will then be provided on what free tooling exists to crack open your JVM and profile your code to identify the slow or defective areas. This will briefly cover how you can achieve this locally, but will focus on monitoring a remote JVM (typical for production scenarios). Finally, we will briefly cover how you can further map what system level operations are being invoked from the JVM to understand what limitations it may be facing. The examples provided will be tailored to the Oracle HotSpot JVM in a Linux environment.
