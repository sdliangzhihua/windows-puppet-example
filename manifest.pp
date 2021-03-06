
#Create a PowerShell script to download Notepad++

 file { 'C:\Users\Administrator\Desktop\Puppet\DownloadNotepad.ps1':
    ensure      => 'file',
    mode        => '0770',
    owner       => 'Administrator',
    group       => 'Administrators',
    content     => '$webClient = New-Object System.Net.webclient
                    $sourceURL = "http://download.tuxfamily.org/notepadplus/6.5.4/npp.6.5.4.Installer.exe"
                    $destPath = "C:\Users\Administrator\Desktop\Puppet\npp.6.5.4.Installer.exe"
                    <#Check to see if the file has been downloaded before, download the file only if it does not exist.#>
                    if ((Test-path $destPath) -eq $true) {
                      "File Exists"
                    }
                    else {
                      $webClient.DownloadFile($sourceURL, $destPath)
                    }',
   before      => Exec ['DownloadNotepad'],
  }

#Download Notepad++ if the file does not exist

  exec { 'DownloadNotepad':
    command     => 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -executionpolicy remotesigned C:\Users\Administrator\Desktop\Puppet\DownloadNotepad.ps1',
    creates     => 'C:\Users\Administrator\Desktop\Puppet\npp.6.5.4.Installer.exe',
    before      => Package ['Notepad++'],
	}


#Install package Notepad++ Version 6.5.4

  package { 'Notepad++':
    ensure      => installed,
    source      => 'C:\\Users\\Administrator\\Desktop\\Puppet\\npp.6.5.4.Installer.exe',
    install_options     => ['/S'],
  }


#Add a new user

  user { 'elvis':
    ensure        => present,
    password      => "E1v!s@c0td",
  }


#Stop the service "puppet"

  service { 'puppet':
    ensure        => stopped,
    enable        => true,
  }


#Create a batch file to write date to "C:\date.txt"

  file { 'C:\Users\Administrator\Desktop\Puppet\LogDate.bat':
    ensure      => 'file',
    mode        => '0770',
    owner       => 'Administrator',
    group       => 'Administrators',
    content     => 'date /t >> c:\date.txt',
    before      => File ['C:\Users\Administrator\Desktop\Puppet\CreateSchedTask.bat'],
  }
  
#Create a batch file for creating the schedule task.
#Can't use the Puppet's scheduled_task as it does not support to run the schedule taks every 5 minutes.

  file { 'C:\Users\Administrator\Desktop\Puppet\CreateSchedTask.bat':
    ensure      => 'file',
    mode        => '0770',
    owner       => 'Administrator',
    group       => 'Administrators',
    content     => 'schtasks /create /sc MINUTE /mo 5 /tn LogDateTask /tr C:\Users\Administrator\Desktop\Puppet\LogDate.bat /ru SYSTEM /f',
  }

  
#Run the batch file "CreateSchedTask.bat" to create the schedule task to run every 5 minutes.

  exec { 'CreateSchedTask':
    command     => 'C:\Users\Administrator\Desktop\Puppet\CreateSchedTask.bat',
    subscribe   => File ['C:\Users\Administrator\Desktop\Puppet\CreateSchedTask.bat'],
	onlyif => ["C:\\Windows\\system32\\cmd.exe /C schtasks /query /tn LogDateTask & if errorlevel 1 (exit /b 0) else exit /b 1"],
  }

  
#  scheduled_task { 'DateLogTask':
#    ensure     => present,
#    enabled    => true,
#    user       => 'Administrator',
#    password   => "5LVpafoprchth-mel",
#    command    => 'C:\Users\Administrator\Desktop\Puppet\LogDate.bat',
#    trigger    => {
#      schedule => daily,
#      every    => 5,
#      start_date       => '2014-02-25',
#      start_time       => '21:00',
#    }
#  }




