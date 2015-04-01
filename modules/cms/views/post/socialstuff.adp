
<style type="text/css">
 #share-buttons {
	 background-color: #8FCDF1;
    border: 1px solid #E0DDDD;
    border-radius: 10px 10px 10px 10px;
    padding: 4px;
    
    color: #FFFFFF !important;
    font-family: Indie Flower;
    font-size: 20px;
    font-weight: bold;
 }
#share-buttons img {
width: 35px;
padding: 5px;
border: 0;
box-shadow: 0;
display: inline;
}
 
</style>

<!-- I got these buttons from simplesharebuttons.com -->
<div id="share-buttons">
<%= [mc Share]! %>
<!-- Facebook -->
<% set share_link "[ns_conn location][ns_conn url]"
set pageTitle [$model get title]
%>
<a href="http://www.facebook.com/sharer.php?u=<%=  $share_link; %>" title="Share on Facebook" target="_blank">
<img src="/img/share/facebook.png" alt="Facebook" /></a>

<!-- Twitter -->
<a href="http://twitter.com/share?url=<%=  $share_link; %>&text=<%= $pageTitle; %>" target="_blank"><img src="/img/share/twitter.png" alt="Twitter" /></a>

<!-- Google+ -->
<a href="https://plus.google.com/share?url=<%=  $share_link; %>" target="_blank"><img src="/img/share/google.png" alt="Google" /></a>

<!-- Digg -->
<a href="http://www.digg.com/submit?url=<%=  $share_link; %>" target="_blank"><img src="/img/share/diggit.png" alt="Digg" /></a>

<!-- Reddit -->
<a href="http://reddit.com/submit?url=<%=  $share_link; %>&title=<%= $pageTitle; %>" target="_blank"><img src="/img/share/reddit.png" alt="Reddit" /></a>

<!-- LinkedIn -->
<a href="http://www.linkedin.com/shareArticle?mini=true&url=<%=  $share_link; %>" target="_blank"><img src="/img/share/linkedin.png" alt="LinkedIn" /></a>

<!-- Pinterest -->
<a href="javascript:void((function()%7Bvar%20e=document.createElement('script');e.setAttribute('type','text/javascript');e.setAttribute('charset','UTF-8');e.setAttribute('src','http://assets.pinterest.com/js/pinmarklet.js?r='+Math.random()*99999999);document.body.appendChild(e)%7D)());"><img src="/img/share/pinterest.png" alt="Pinterest" /></a>

<!-- StumbleUpon-->
<a href="http://www.stumbleupon.com/submit?url=<%=  $share_link; %>&title=<%= $pageTitle; %>" target="_blank"><img src="/img/share/stumbleupon.png" alt="StumbleUpon" /></a>

<!-- Email -->
<a href="mailto:?Subject=United Brain Power<%= $pageTitle; %> &Body=I%20saw%20this%20and%20thought%20of%20you!%20 <%=  $share_link; %>"><img src="/img/share/email.png" alt="Email" /></a>

</div>
