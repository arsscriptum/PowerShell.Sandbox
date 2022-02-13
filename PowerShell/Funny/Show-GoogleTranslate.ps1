<#
            .Synopsis
            A simple function to invoke internet explorer and show google translate using powershell
            .DESCRIPTION
            A simple function to invoke internet explorer and show google translate using powershell
            .EXAMPLE
            Show-GoogleTranslate -From English -To 'Chinese Simplified' -Text "Hello good morning $env:USERNAME"

            Description 
            ----------- 
            By Default the cmdlet will use the IE parameterset and display the translation in an IE window
            .EXAMPLE
            Show-GoogleTranslate -From English -To French -Text "Have a Good day $env:USERNAME" -Console

            Description 
            ----------- 
            Using the 'Console' switch will display the output in the powershell console but be aware the html parsing messes up the output so some characters may show up as weird icons.
            .INPUTS
            String
            .OUTPUTS
            Opens Internet Explorer with google translate
            .NOTES
            Author      : Kiran Reddy
            WebSite   : Kiran-Reddy.in
#>

Function Show-GoogleTranslate
{
      [CmdletBinding(DefaultParametersetName = 'IE')]
      param
      (
            [ValidateSet('Afrikaans','Albanian','Arabic','Azerbaijani','Basque','Bengali','Belarusian','Bulgarian','Catalan','Chinese Simplified','Chinese Traditional','Croatian',
                        'Czech','Danish','Dutch','English','Esperanto','Estonian','Filipino','Finnish','French','Galician','Georgian','German','Greek','Gujarati','Haitian Creole',
                        'Hebrew','Hindi','Hungarian','Icelandic','Indonesian','Irish','Italian','Japanese','Kannada','Korean','Latin','Latvian','Lithuanian','Macedonian','Malay',
                        'Maltese','Norwegian','Persian','Polish','Portuguese','Romanian','Russian','Serbian','Slovak','Slovenian','Spanish','Swahili','Swedish','Tamil','Telugu',
                  'Thai','Turkish','Ukrainian','Urdu','Vietnamese','Welsh','Yiddish')
            ]
            [String]$From = 'English',

            [ValidateSet('Afrikaans','Albanian','Arabic','Azerbaijani','Basque','Bengali','Belarusian','Bulgarian','Catalan','Chinese Simplified','Chinese Traditional','Croatian',
                        'Czech','Danish','Dutch','English','Esperanto','Estonian','Filipino','Finnish','French','Galician','Georgian','German','Greek','Gujarati','Haitian Creole',
                        'Hebrew','Hindi','Hungarian','Icelandic','Indonesian','Irish','Italian','Japanese','Kannada','Korean','Latin','Latvian','Lithuanian','Macedonian','Malay',
                        'Maltese','Norwegian','Persian','Polish','Portuguese','Romanian','Russian','Serbian','Slovak','Slovenian','Spanish','Swahili','Swedish','Tamil','Telugu',
                  'Thai','Turkish','Ukrainian','Urdu','Vietnamese','Welsh','Yiddish')
            ]
            [String]$To,

            [String]$Text,

            [Parameter(parametersetname='IE' )]
            [Switch]$ShowIE,

            [Parameter(parametersetname='Console' )]
            [Switch]$Console
      )


      $LanguageHashTable = 
      @{
            Afrikaans='af'
            Albanian='sq'
            Arabic='ar'
            Azerbaijani='az'
            Basque='eu'
            Bengali='bn'
            Belarusian='be'
            Bulgarian='bg'
            Catalan='ca'
            'Chinese Simplified'='zh-CN'
            'Chinese Traditional'='zh-TW'
            Croatian='hr'
            Czech='cs'
            Danish='da'
            Dutch='nl'
            English='en'
            Esperanto='eo'
            Estonian='et'
            Filipino='tl'
            Finnish='fi'
            French='fr'
            Galician='gl'
            Georgian='ka'
            German='de'
            Greek='el'
            Gujarati='gu'
            Haitian ='ht'
            Creole='ht'
            Hebrew='iw'
            Hindi='hi'
            Hungarian='hu'
            Icelandic='is'
            Indonesian='id'
            Irish='ga'
            Italian='it'
            Japanese='ja'
            Kannada='kn'
            Korean='ko'
            Latin='la'
            Latvian='lv'
            Lithuanian='lt'
            Macedonian='mk'
            Malay='ms'
            Maltese='mt'
            Norwegian='no'
            Persian='fa'
            Polish='pl'
            Portuguese='pt'
            Romanian='ro'
            Russian='ru'
            Serbian='sr'
            Slovak='sk'
            Slovenian='sl'
            Spanish='es'
            Swahili='sw'
            Swedish='sv'
            Tamil='ta'
            Telugu='te'
            Thai='th'
            Turkish='tr'
            Ukrainian='uk'
            Urdu='ur'
            Vietnamese='vi'
            Welsh='cy'
            Yiddish='yi'
      }


      if ($pscmdlet.ParameterSetName -eq 'IE')
      {
            $IE = New-Object -ComObject Internetexplorer.Application
            $URL = 'http://translate.google.com/#{0}/{1}/{2}'   -f  $LanguageHashTable[$from],  $LanguageHashTable[$to],  $Text
            $IE.Navigate($url)
            $IE.Visible = $true
           
      }

      if ($pscmdlet.ParameterSetName -eq 'Console')
      {
            $URL = 'http://www.google.com/translate_t?hl=en&ie=UTF8&text={0}&langpair={1}|{2}' -f $Text, $LanguageHashTable[$from],  $LanguageHashTable[$to]
            $WebClient = New-Object System.Net.WebClient
            $WebClient.Encoding = [System.Text.Encoding]::UTF8
            $Result = $WebClient.DownloadString($url)

            $TrResult = $Result.Substring($Result.IndexOf('id=result_box') + 22, 1000);
            [regex]::Match($TrResult,'(?s)(?<=onmouseout.*\>).*?(?=\<)')|  ForEach-Object { $_.Groups.value  -replace '&#39;' ,"'"}
           
      }
}



#Example
#Show-GoogleTranslate -From English -To French -Text "Have a Good day $env:USERNAME" -Console
