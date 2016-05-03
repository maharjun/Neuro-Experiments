# Experiment Repository User Guide

##  Folder Structure

There are 3 Kinds of Folders

1.  Experiment Folders
2.  Intermediate Folders
3.  Submodule Folders

The root directory is a special type of Intermediate Folder.

###   Experiment Folder

This folder contains all the code relevant to a set of self-contained experi-ments. It also contains a file explog.yml which details the experiments being performed. Further requirements for experiments are detailed below.

###   Intermediate folder

This folder is a folder that does not contain experiment code, instead, it contains directories that are either experiment directories, intermediate directories, or submodule directories.

###   Submodule Directory

A submodule directory is basically a directory that contains the git repo-sitory for a submodule necessary for the simulations. They are centrally stored under the `<TopLevelDir>/Submodules` directory.

---------------------------------------------------------------------------

##  Folder Details

Each of the above directories have the following requirements.

###   For Every Experiment/Intermediate Folder (Except Top)

In each folder, There will exist a file `folderinfo.yml` which will be of the following format:

```yaml
ID          : <The Unique ID (as 32-bit hex string) assigned>
ParentID    : <The Unique ID (as 32-bit hex string) assigned to Parent Folder>
Title       : <The Title (Indicates Purpose of Folder)>
Description : |
  Detailed Description 
  (Markdown from Level-3 Header Onwards)
```

###   For Intermediate Folders Except Top

There is to be no file except the above mentioned `FolderDetails.yml` in any Intermediate Directory

###   In Every Experiment Folder

In Every Experiment Folder, there must, in addition, also exist a file 
`explog.yml` of the following format

```yaml
ExpFolderID: <The Unique 32-bit ID of the Experiment Folder>
NumberofEntries: <The number of experiment entities stored>
ExpEntries:
- ID          : <The Unique 32-bit ID assigned to Current Experiment>
  Title       : <Title Describing Experiment>
  Description : |
    The Detailed description of the experiment,
    including any special instructions apart from the
    setup script. This is to be written in Markdown 
    (level-3 header onwards).
    
    Roughly break it down into 4 Steps
    
    1. Procedure
    2. Observations
    3. Inference
    4. Future Work

- ID          :
  Title       :
  Description :
  
  # And So On
  # ...
 
```

##  Management Files

###   RSAKeys.yml

This is a simple file containing the following data used by the RSA algorithm to encode and decode the unique ID into the currently last sequential Number.

###   EntityData.yml

This is the central YAML file that keeps track of all the ID's issued up until this commit. This file will be updated when the Numbers are booked.

```yaml
ID          : <Unique ID of Item>
ParentID    : <Unique ID of Parent Directory. 0..32 times..0 if Parent is root>
Type        : <One of ('IntermediateDir' 'ExperimentDir' 'Experiment') >
Path        : <Path of the Item. This is iff Type=Directory>
```

## Instructions

###   Taking out a new branch.

The below is the procedure of forming a branch to work on some experiment(s).

1.  Book your directories and experimentsd with the master branch. This is done as follows:
    
    1.  From the latest commit of the submodule RepoManagement, book the 
        commits, and perform a fast-forward only merge to origin/master. If 
        this works then the numbers have been booked.

    2.  Create all subdirectories along with at least a skeleton of the 
        `FolderDetails.yml` file (i.e. containing the ID and ParentID).

    3.  Create Entries in the `explog.yml` file (if any experiments are 
        booked). The entries must at least contain their ID's mentioned
    
    4.  Steps 2 and 3 can be done via the RepoManagement scripts
    
    __hopefully, at-least steps 1-3 can be automated using python.__

2.  
2.  Record your experiment along with setup instructions.
    
3.  Before committing, run the validation script of RepoManagement. If it 
    returns all ok, then commit the changes. This commit should not face any 
    merge conflicts

##  Motivations

1.  Booking ID's is kept in a separate submodule in order to decouple the 
    process from the branching of the experiment repository. The Repo 
    Management is a CVS designed to provide unambiguous booking numbers to the 
    different people working on different experiments.

2.  In the event that one wants to create a separate branch and not share 
    documentation (secret experiments for e.g.), the framework allows you to 
    maintain a separate branch in the Experiment repository having unique ID's 
    booked in the Repo Management submodule without having to merge the branch 
    with the master branch.

3.  In the event that one wishes to add a submodule, we'll think about that 
    later.

## Deleting records

A Deleted record basically means that a given record is deleted from the table 
in EntityData.yml. In case this entity is a directory, all the children and 
descendents will have their entries deleted. In this case, it basically means 
that the given directory no longer exists. However, unless the directory is 
explicitly deleted, this doesnt do much except leave the directory and its 
contents unaccounted for.

Deleting a directory is serious business. It is not an operation that can be undone except by going back in history. But even in this case, it will become impossible if the ID's that were deleted are overwritten. Hence, we make the overwriting of ID's impossible. i.e. once a set of ID's have been booked (i.e. committed to the RepoManagement repository), Any deletion of any of those ID's will leave a permanent 'hole' in the records. 

Until the booking is confirmed (via a successful feed-forward commit), any directory may be unbooked (in which case, all the ID's will be changed so that ID's are seqential)