
```mermaid
flowchart LR
    a --> b --> id1[(d)]
    b --> c
    c --> id1[(d)]
```



<br />
<br /><br /><br /><br /><br />





```mermaid
flowchart LR
    a[api gateway] --> b[location]
    a --> c[alert]
    a --> d[weather]
    b --> id1[(location_db)]
    b --> f[cdn]
    c --> id2[(alert_db)]
    d --> id3[(weather_db)]
    b & c & d --> e[lock]
```


                <section>
                    <div class="mermaid" style="max-width: 100%; height: auto;">
                        <pre>
                          %%{init: {'theme': 'dark', 'themeVariables': { 'darkMode': true }}}%%
                          flowchart LR
                              a[api gateway <br />] --> b[location]
                              a --> c[alert]
                              a --> d[weather]
                              b --> id1[(location_db)]
                              b --> f[cdn]
                              c --> id2[(alert_db)]
                              d --> id3[(weather_db)]
                              b & c & d --> e[lock]
                        </pre>
                      </div>
                </section>