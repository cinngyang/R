# R
R 語言學習<br>

***

[80/20 法則資料演練](ParetoPrinciple.ipynb)<br>[dplyr](dplyr.ipynb/)<br>[tidry](tidry.ipynb)<br>[BOM分析使用tidyr](/tidyr_Reshap.ipynb)<br>[ReShap2 樞紐](/ReShap2.ipynb/)<br>[ggplot2](ggplot2.ipynb)<br>[ggmap](R-ggmap.ipynb)<br>[Cluster](/Cluster.ipynb/)<br>

癡呆區-常忘<br>

conda 安裝 R package 
conda install -c conda-forge r-ggplot2<br>
conda install -c defaults zeromq (Fixed R kernel in Jupyter keeps dying)<br>[Fixed there is no package called 'IRkernel'](https://irkernel.github.io/installation/)<br>

> Jupyter 隱藏 code
>
> library(IRdisplay) 
>
> display_html(
>
> '<script>  
>
> code_show=true; 
>
> function code_toggle() {
>
>   if (code_show){
>
> ​    $(\'div.input\').hide();
>
>   } else {
>
> ​    $(\'div.input\').show();
>
>   }
>
>   code_show = !code_show
>
> }  
>
> $( document ).ready(code_toggle);
>
> </script>
>
>   <form action="javascript:code_toggle()">
>
> ​    <input type="submit" value="Click here to toggle on/off the raw code.">
>
> </form>'
>
> )