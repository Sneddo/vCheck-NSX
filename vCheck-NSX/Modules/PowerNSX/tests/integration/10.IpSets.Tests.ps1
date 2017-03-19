#PowerNSX IPSet Tests.
#Nick Bradford : nbradford@vmware.com

#Because PowerNSX is an API consumption tool, its test framework is limited to
#exercising cmdlet functionality against a functional NSX and vSphere API
#If you disagree with this approach - feel free to start writing mocks for all
#potential API reponses... :)

#In the meantime, the test format is not as elegant as normal TDD, but Ive made some effort to get close to this.
#Each functional area in NSX should have a separate test file.

#Try to group related tests in contexts.  Especially ones that rely on configuration done in previous tests
#Try to make tests as standalone as possible, but generally round trips to the API are expensive, so bear in mind
#the time spent recreating configuration created in previous tests just for the sake of keeping test isolation.

#Try to put all non test related setup and tear down in the BeforeAll and AfterAll sections.  ]
#If a failure in here occurs, the Describe block is not executed.

#########################
#Do not remove this - we need to ensure connection setup and module deps preload have occured.
If ( -not $PNSXTestNSXManager ) {
    Throw "Tests must be invoked via Start-Test function from the Test module.  Import the Test module and run Start-Test"
}

Describe "IPSets" {

    BeforeAll {

        #BeforeAll block runs _once_ at invocation regardless of number of tests/contexts/describes.
        #We load the mod and establish connection to NSX Manager here.

        #Put any setup tasks in here that are required to perform your tests.  Typical defaults:
        import-module $pnsxmodule
        $script:DefaultNsxConnection = Connect-NsxServer -Server $PNSXTestNSXManager -Credential $PNSXTestDefMgrCred -DisableVIAutoConnect

        #Put any script scope variables you need to reference in your tests.
        #For naming items that will be created in NSX, use a unique prefix
        #pester_<testabbreviation>_<objecttype><uid>.  example:
        $script:IpSetPrefix = "pester_ipset_"

        #Clean up any existing ipsets from previous runs...
        get-nsxipset | ? { $_.name -match $IpSetPrefix } | remove-nsxipset -confirm:$false


    }

    AfterAll {
        #AfterAll block runs _once_ at completion of invocation regardless of number of tests/contexts/describes.
        #Clean up anything you create in here.  Be forceful - you want to leave the test env as you found it as much as is possible.
        #We kill the connection to NSX Manager here.

        get-nsxipset | ? { $_.name -match $IpSetPrefix } | remove-nsxipset -confirm:$false

        disconnect-nsxserver
    }

    Context "IpSet retrieval" {
        BeforeAll {
            $script:ipsetName = "$IpSetPrefix-get"
            $ipSetDesc = "PowerNSX Pester Test get ipset"
            $script:get = New-nsxipset -Name $ipsetName -Description $ipSetDesc

        }

        it "Can retreive an ipset by name" {
            {Get-nsxipset -Name $ipsetName} | should not throw
            $ipset = Get-nsxipset -Name $ipsetName
            $ipset | should not be $null
            $ipset.name | should be $ipsetName

         }

        it "Can retreive an ipset by id" {
            {Get-nsxipset -objectId $get.objectId } | should not throw
            $ipset = Get-nsxipset -objectId $get.objectId
            $ipset | should not be $null
            $ipset.objectId | should be $get.objectId
         }
    }

    Context "Successful IpSet Creation" {

        AfterAll {
            get-nsxipset | ? { $_.name -match $IpSetPrefix } | remove-nsxipset -confirm:$false
        }

        it "Can create an ipset with single address" {

            $ipsetName = "$IpSetPrefix-ipset-create1"
            $ipsetDesc = "PowerNSX Pester Test create ipset"
            $ipaddresses = "1.2.3.4"
            $ipset = New-nsxipset -Name $ipsetName -Description $ipsetDesc -IPAddresses $ipaddresses
            $ipset.Name | Should be $ipsetName
            $ipset.Description | should be $ipsetDesc
            $get = Get-nsxipset -Name $ipsetName
            $get.name | should be $ipset.name
            $get.description | should be $ipset.description
            $get.value | should be $ipset.value

        }

        it "Can create an ipset with range" {

            $ipsetName = "$IpSetPrefix-ipset-create2"
            $ipsetDesc = "PowerNSX Pester Test create ipset"
            $ipaddresses = "1.2.3.4-2.3.4.5"
            $ipset = New-nsxipset -Name $ipsetName -Description $ipsetDesc -IPAddresses $ipaddresses
            $ipset.Name | Should be $ipsetName
            $ipset.Description | should be $ipsetDesc
            $get = Get-nsxipset -Name $ipsetName
            $get.name | should be $ipset.name
            $get.description | should be $ipset.description
            $get.value | should be $ipset.value

        }

        it "Can create an ipset with CIDR" {

            $ipsetName = "$IpSetPrefix-ipset-create3"
            $ipsetDesc = "PowerNSX Pester Test create ipset"
            $ipaddresses = "1.2.3.0/24"
            $ipset = New-nsxipset -Name $ipsetName -Description $ipsetDesc -IPAddresses $ipaddresses
            $ipset.Name | Should be $ipsetName
            $ipset.Description | should be $ipsetDesc
            $get = Get-nsxipset -Name $ipsetName
            $get.name | should be $ipset.name
            $get.description | should be $ipset.description
            $get.value | should be $ipset.value

        }


        it "Can create an ipset and return an objectId only" {
            $ipsetName = "$IpSetPrefix-objonly-1234"
            $ipsetDesc = "PowerNSX Pester Test objectidonly ipset"
            $ipaddresses = "1.2.3.4"
            $id = New-nsxipset -Name $ipsetName -Description $ipsetDesc -IPAddresses $ipaddresses -ReturnObjectIdOnly
            $id | should BeOfType System.String
            $id | should match "^ipset-\d*$"

         }
    }

    Context "Unsuccessful IpSet Creation" {

        it "Fails to create an ipset with invalid address" {

            $ipsetName = "$IpSetPrefix-ipset-create1"
            $ipsetDesc = "PowerNSX Pester Test create ipset"
            $ipaddresses = "1.2.3.4.5"
            { New-nsxipset -Name $ipsetName -Description $ipsetDesc -IPAddresses $ipaddresses } | should throw
        }
    }


    Context "IpSet Deletion" {

        BeforeEach {
            $ipsetName = "$IpSetPrefix-delete"
            $ipsetDesc = "PowerNSX Pester Test delete IpSet"
            $script:delete = New-nsxipset -Name $ipsetName -Description $ipsetDesc

        }

        it "Can delete an ipset by object" {

            $delete | Remove-nsxipset -confirm:$false
            {Get-nsxipset -objectId $delete.objectId} | should throw
        }

    }
}