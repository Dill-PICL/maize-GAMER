for f in $@
do
	file=`basename $f | sed 's/.xml//g'`
	echo $f $in_file

echo "#This is a configuration file to be used with PANNZER program.
#The file is read by a Python ConfigParser class 
#http://docs.python.org/library/configparser.html.
#Everything specified in this file should be done in the style 
#of http://tools.ietf.org/html/rfc822.html

[GENERAL_SETTINGS]
#Input file type [SANS, BLASTXML] (BLASTXML recommended, SANS not yet supported!)
INPUT_TYPE=BLASTXML

#Blast file name, it should be located under the RESULT_FOLDER (see few lines below)
INPUT_FILE=$file.xml

#Is the blast file in XML format or not
XML=True

#Folder where db and taxonomy files can be found 
DATA_FOLDER=/home/gokul/lab_data/go_annotation/trial2/cafa_sw/PANNZER/db/

#Database file name, it should be located under the DATA_FOLDER
DB=UNIPROTClean.tab

#Folder to save result in 
RESULT_FOLDER=/home/gokul/lab_data/go_annotation/trial2/cafa_sw/PANNZER/output/

#Base name for result files
RESULT_BASE_NAME=$file

#Base name for input files, if multispecies analysis are used (MULTIPLE_SPECIES must be True).
INPUT_BASE_NAME=Prefix_of_the_desc_file

#Folder where all the input files are
INPUT_FOLDER=/home/gokul/lab_data/go_annotation/trial2/cafa_sw/PANNZER/xml/

#If you don't know the taxonTree for the species, you can either give here name or the taxonId here and set GET_TAXON=True
QUERY_TAXON=####

#Only set this True when you don't know the taxonTree for your specie
GET_TAXON=False

#If you want to generate IDF table from the database, this is needed everytime you change the database used. 
GENERATE_IDF=True

#If you have multiple species in your sequence set. Requires .desc file, please check manual.
MULTIPLE_SPECIES=False

[TRESHOLD_VALUES]

#Treshold for the bitscore
BITSCORE=50

#If sequence length is shorter than this, it will not be handled 
SEQUENCE_LENGTH=20

#Sequence identity % has to exceed this (possible values 0-100)
IDENTITY_PERCENT=50

#Hit e-value has to exceed this, NOT USED AT THE MOMENT
E-VALUE=0

#Alignment has to cover this portion from target sequence (possible values 0.0-1.0)
TARGET_COVERAGE=0.6

#Alignment has to cover this portion from query sequence (possible values 0.0-1.0)
QUERY_COVERAGE=0.6

#Description is counted as informative when it's information density score exceeds this
INFORMATIVE=30

#If this set 0, then parser goes trought the whole Blast/SANS list, otherwise stops when the amount of informative sequences are exceed
INFORMATIVE_HITS=100

#Maximun TF-IDF distance between two description to be clustered together
CLUSTER=0.3

[MYSQL]

#NOTE! You only need to specify these setting if you're running 
#      PANNZER with MySQL database

#Define MySQL host server. Defaults to localhost
SQL_DB_HOST=localhost

#Define port to the server, defaults to None
SQL_DB_PORT =

#MySQL DB user 
SQL_DB_USER = root

#MySQL user password
SQL_DB_PASSWORD = bot566466


#MySQL DB to be used
SQL_DB = pannzer

[TAXONOMY]
#Name of the taxonomy db file
DB=taxonomy-all.tab

#If set False, taxonomic distance doesn't affect the results
CALCULATE=True

#Set the taxonomic level to sort out the main levels of results (e.g. 1 = Bacteria, Archaea, Eukaryota, etc.)
NODE_SELECTOR=1

#If you want to track certain groups or species put it to True. If False, then setting TRACKED_GROUPS doesn't affect
TRACK_GROUPS=False

#List here the groups you want to track (example TRACKED_GROUPS=1;234;9000). NOTE: only works with taxonomic id's
TRACKED_GROUPS=

#If you want to count only best hit from each species, then set this parameter to True
ONLY_ONE_HIT_PER_SPECIE=False

[GO]
#If you want to generate GO and EC classes for result clusters
WRITE_GO=True

#physical path to the Geneontology OBO file
OBO=gene_ontology_ext.obo

#Specify location for "IDMAPPING" file
ID_MAPPING=idmapping_selected.tab

#Specify location for "enzyme.dat" file
ENZYME=enzyme.dat

[LEVEL_OF_PRINTING]
# Simple output file format. Prints only necessities from predictions (DE's and GO's with one score per result). Simple output recommended!!!
SIMPLE_OUTPUT=True

#If you want to print all clusters
CLUSTER=True

#If you want to print all clusters members
CLUSTER_MEMBERS=False

#If you want to print all hits
ALL=False

#If you want to print possible error's messages
ERROR=True

#If you want to print debug level messages
DEBUG=False

#If you want to print info level messages
INFO=False

[EVALUATION] ### IF YOU DON'T KNOW WHAT YOU ARE DOING, DON'T CHANGE ANYTHING FROM THIS ON!!!!

#For evaluation purposes, prints out values for regression function
PRINT_EVAL=False

#If this is set as False, then the parameters under this don't affect the settings and are not read
TEST=False

#For any other evaluation dataset
OTHER=False" > config/$file.conf
#python run.py config/$file.conf
done
ls config/* | parallel -i -j 4 python run.py {}
