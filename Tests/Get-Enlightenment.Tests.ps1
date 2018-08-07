#Requires -Module PSKoans

InModuleScope 'PSKoans' {
    Describe 'Get-Enlightenment' {

        Context 'Default Behaviour' {
            BeforeAll {
                Mock Clear-Host
                Mock Write-MeditationPrompt
                Mock Invoke-Pester
            }

            It 'should not produce output' {
                Get-Enlightenment | Should -Be $null
            }

            It 'should clear the screen' {
                Assert-MockCalled Clear-Host -Times 1
            }

            It 'should write the meditation prompts' {
                Assert-MockCalled Write-MeditationPrompt -Times 2
            }

            It 'should Invoke-Pester on each of the koans' {
                $ValidKoans = Get-ChildItem "$env:PSKoans_Folder" -Recurse -Filter '*.Koans.ps1' |
                    Get-Command {$_.FullName} |
                    Where-Object {$_.ScriptBlock.Attributes.TypeID -match 'KoanAttribute'}

                Assert-MockCalled Invoke-Pester -Times ($ValidKoans.Count)
            }
        }

        Context 'With -Reset Switch' {
            BeforeAll {
                Mock Initialize-KoanDirectory
            }

            It 'should not produce output' {
                Get-Enlightenment -Reset | Should -BeNullOrEmpty
            }

            It 'should call Initialize-KoanDirectory' {
                Assert-MockCalled Initialize-KoanDirectory -Times 1
            }
        }

        Context 'With -Meditate Switch' {

            Context 'VS Code Installed' {
                BeforeAll {
                    Mock Get-Command {$true}
                    Mock Start-Process {$FilePath}
                }

                It 'should start VS Code with Start-Process' {
                    Get-Enlightenment -Meditate | Should -Be 'code'

                    Assert-MockCalled Get-Command -Times 1
                    Assert-MockCalled Start-Process -Times 1
                }
            }

            Context 'VS Code Not Installed' {
                BeforeAll {
                    Mock Get-Command {$false}
                    Mock Invoke-Item
                }

                It 'should not produce output' {
                    Get-Enlightenment -Meditate | Should -BeNullOrEmpty
                }
                It 'should open the koans directory with Invoke-Item' {
                    Assert-MockCalled Get-Command -Times 1
                    Assert-MockCalled Invoke-Item -Times 1
                }
            }
        }
    }
}