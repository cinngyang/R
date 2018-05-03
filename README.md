# R
R 語言學習<br>

conda 安裝 R package 
conda install -c conda-forge r-ggplot2<br>
conda install -c defaults zeromq (Fixed R kernel in Jupyter keeps dying)<br>
[Fixed there is no package called 'IRkernel'](https://irkernel.github.io/installation/)<br>

Jupyter 顯示或隱藏 code
```
library(IRdisplay)

display_html(
'<script>  
code_show=true; 
function code_toggle() {
  if (code_show){
    $(\'div.input\').hide();
  } else {
    $(\'div.input\').show();
  }
  code_show = !code_show
}  
$( document ).ready(code_toggle);
</script>
  <form action="javascript:code_toggle()">
    <input type="submit" value="Click here to toggle on/off the raw code.">
 </form>'
)
```
***



[dplyr](/dplyr.ipynb/)<br>[ggplot2](ggplot2.ipynb)<br>[ggmap](/R-ggmap.ipynb/)<br>[ReShap2 樞紐](/ReShap2.ipynb/)<br>[Cluster](/Cluster.ipynb/)<br>
