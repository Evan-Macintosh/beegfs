### Overview
This is my silly little repo where I'm holding my BeeGFS related scripts in case I need them in the future. In it, you'll find my process for creating my super bare bones, hyper converged BeeGFS "cluster".

### BeeGFS vs. its competition
Here were my alternatives and why I didn't pick them
- GPFS
  - I don't currently have the servers required to support this in a way that I find acceptable (if I did this, I'd want at least 10 SSDs for the system tier and 60 disks for capacity tier)
  - The community version doesn't allow a namespace over 12TB (without lobotomizing your install in a way I don't care to figure out at current moment (allegedly))
- Lustre
  - I'm neither James Simmons nor Oleg Drokin
- MooseFS
  - really? next
- GFS2
  - I'm not running RHEL in my environment, so I don't really see this as a viable option
- Ceph
  - Sounds like a good idea, but for future plans of mine it's not super cool.
  - Rook is nice at face value, but in my little experience with it, it really like to purple nurple your networking in a way I can't be bothered to really un-nurple (thanks Kubernetes)
  - Whether using Rook or "raw" Ceph, I've not had good luck getting it working. The former (IDR, I must've flushed that from my memory), the latter just doesn't seem to have excellent support and getting things properly hitting Ceph repos is a nightmare
  - The documentation on what Ceph does to your hardware (1 OSD per core, 1GB memory/TB disk) and what it doesn't allow you to do (multipath specifically) sounds very unappealing
  - The """""minimum viable system""""" is 3 (5?) nodes, which for my use case is obscene. It says you *can* get away with smaller, but I don't feel like poking that, especially given the above

 So why BeeGFS then?
   - The documentation is written in a way that I don't hate (it's written in plain English and is pleasant to read)
   - I can use whatever underlying hardware I please (in this case a NetApp w/ SAS drives attached via a cable to each of two LSI HBAs)
   - I can use whatever filesystem format I please, either backing or topical (ext4/xfs on top of zpools)
   - It was the filesystem that helped Katie Bouman and her team generate the famous first picure of a black hole
   - In the future, I can enable RoCEv2 with extreme ease
   - Also in the future (I think), I can implement things like pacemaker/corosync


### My current configuration
My BeeGFS system looks like such
```
+-- lcs-s1 -------------+
| Xeon E5-4657L v2      |
| 64GB DDR3 ECC         |
|     10 GbE SFP+ NIC   +------> switch
|                       +
|          LSI 9207-8e  +
|                       +------> +===============================+
|                       |        | NetApp E2724 w/ 24x 900GB SAS |
|          LSI 9207-8e  +------> +===============================+
|                       +
|    Team 256G SATA SSD |
|    Team 256G SATA SSD |
+-----------------------+
```

### Future plans
Uh, these are really far off, but
1) I/O nodes be a pair of identical servers w/ ability to use U.2 disks for metadata and at least Skylake processors
2) HA working across more than 1 I/O node (Buddy Groups at very least, maybe corosync/pacemaker? (this may require the know-how and maybe some engineering work))
3) RoCEv2 capable hardware running at >=40GbE
4) 1 or more DDN SS8460 shelves 
