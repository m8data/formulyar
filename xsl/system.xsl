<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="html" version="1.0" encoding="UTF-8"/>
	<!--<xsl:variable name="ctrl" select="'system'"/>
		<xsl:param name="temp" select="/*"/>
	<xsl:include href="/m8data/a/lib/xslt/interface.xsl"/>
	<xsl:template name="TitleAndMisk">
		<title>Базовый</title>
	</xsl:template>
	<xsl:template name="startBody"></xsl:template>
	<xsl:template name="notFocus">без запроса</xsl:template>	//-->
	<xsl:param name="temp" select="/*"/>
	<xsl:param name="author" select="/*/@author"/>
	<xsl:param name="avatar" select="/*/@avatar"/>
	<xsl:param name="ctrl" select="/*/@ctrl"/>
	<xsl:param name="fact" select="/*/@fact"/>
	<xsl:param name="moment" select="/*/@moment"/>
	<xsl:param name="login" select="/*/@login"/>
	<xsl:param name="user" select="/*/@user"/>
	<xsl:param name="tempAuthor" select="/*/@tempAuthor"/>
	<xsl:param name="new_author" select="/*/@new_author"/>
	<xsl:param name="new_avatar" select="/*/@new_avatar"/>
	<!--<xsl:param name="password" select="/*/@password"/>
	<xsl:param name="new_password" select="/*/@new_password"/>
	<xsl:param name="new_password2" select="/*/@new_password2"/>-->
	<xsl:param name="quest" select="/*/@quest"/>
	<xsl:param name="questID" select="/*/@questID"/>
	<xsl:param name="object" select="/*/@object"/>
	<xsl:param name="objectID" select="/*/@objectID"/>
	<!--<xsl:param name="questFile" select="concat( '/m8/n0/', $quest, '/', $author, '/index.xml' )"/>-->
	<xsl:param name="script" select="$objectID"/>
	<xsl:param name="m8mode" select="/*/@m8mode"/>
	<xsl:param name="time" select="/*/@time"/>
	<xsl:param name="localtime" select="/*/@localtime"/>
	<xsl:param name="referer" select="/*/@referer"/>
	<xsl:param name="message" select="/*/@message"/>
	<xsl:param name="add" select="/*/@add"/>
	<xsl:param name="del" select="/*/@del"/>
	<xsl:param name="in" select="/*/@in"/>
	<xsl:param name="lenght" select="10"/>
	<!--<xsl:param name="admin" select="'/m8/w0/a'"/>-->
	<xsl:param name="refDirName" select="'index'"/>
	<xsl:param name="stepFile" select="/*/@file"/>
	<xsl:param name="regScript" select="'/$/reg.pl'"/>
	<xsl:param name="controlScript" select="concat($regScript, '?control=', /*/@control)"/>
	<!--

	 -->
	<xsl:template match="/">
		<xsl:message terminate="no">interface match="/"</xsl:message>
		<!--<script type="javascript">alert('dd');</script> onclick="alert(source)"
-->
		<xsl:choose>
			<xsl:when test="/*/@control">
				<xsl:choose>
					<xsl:when test="$user = 'admin'">
						<xsl:call-template name="control"/>
					</xsl:when>
					<xsl:otherwise>
						<html>
							<head>
								<title>Не достаточно прав</title>
							</head>
							<body>Требуются админские полномочия</body>
						</html>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!--<xsl:when test="not(/*/@author)"><xsl:call-template name="auth"/></xsl:when>-->
			<xsl:otherwise>
				<xsl:call-template name="auth"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	<!--

	 -->
	<xsl:template name="auth">
		<html>
			<head>
			
				<!--<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/> это лишне, cgi и так все задает верно
				<script src="/bower_components/platform.js"></script>
				<link rel="import" href="/bower_components/polymer/polymer.html"/>-->
				<script type="text/javascript" src="/formulyar/js/jquery.min-1.9.0.js"/>
				<!--<script type="text/javascript" src="/$/js/form.js"/>-->
				<script type="text/javascript">var source = "";
				</script>
				<!-- 	<title><xsl:value-of select="document('/index.xml')/*/*[@id=$avatar]/@title"/></title> так нельзя ибо аватара может и не быть
				<xsl:call-template name="startHead"/>-->
				<style>a {
				color: blue;
				text-decoration: none;
				}
				a:active {
					color: blue;
					text-decoration: none;
				}
				a:link {
					color: blue;
					text-decoration: none;
				}
				a:visited {
					color: blue;
					text-decoration: none;
				}
				a:focus {
					color: blue;
					text-decoration: none;
				}
				a:hover {
					color: blue;
					text-decoration: none;
				}
				div.page {
					background: white
				}

				</style>
				<!-- 		@media screen and (max-width: 2800px) {
					div.page {			width: 1500px; }
				}
				@media screen and (max-width: 1280px) {
					div.page {width: 1100px;}
				}
				@media screen and (max-width: 980px) {
					div.page {
						width: 980px;
						font-size: 1em;
					}
				}
 -->
			</head>
			<body style="padding: 0; margin: 0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 0.8em; background: gray; text-align: center">
				<!-- onload="onloadBody()"-->
		<xsl:if test="$user != 'guest' or 1">
			<div style="position: absolute; bottom: 5px; left: 5px">
				<a href="/teplotn/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">calculator</a>
				<xsl:text> | </xsl:text>			
				<a href="/xalio/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">edit</a>
				<xsl:text> | </xsl:text>
				<a href="/system/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">refresh</a>
				<xsl:text> | </xsl:text>
				<a href="/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}/port.xml">xml</a>
				<!-- /m8/{substring($fact,1,1)}/{$fact}/{$author}/{$avatar}/{$quest}/port.xml -->
			</div>
			<!--//-->
			<div style="position: absolute; bottom: 5px; right: 5px; color: gray">
				<xsl:value-of select="$time"/>
			</div>
		</xsl:if>				
				
				
				<xsl:if test="$message">
					<div style="position: absolute; bottom: 25px; right: 400px">
						<xsl:value-of select="$message"/>
					</div>
				</xsl:if>
				<!--<link rel="import" href="/bower_components/habrauser-card.html"/>
<div class="hero-unit">
  <habrauser-card habrauser="Petya" usercolor="red">This text from index.html</habrauser-card>
  <habrauser-card habrauser="Ivan"><h3>Hello!</h3> The end text!</habrauser-card>
  <habrauser-card usercolor="blue"><input placeholder="type here"/></habrauser-card>
</div>

<dom-module id="dom-element">

  <template>
    <p>I'm a DOM element. This is my local DOM!</p>
  </template>

  <script>
    Polymer({
      is: "dom-element"
    });
  </script>

</dom-module>-->
				<div style="width: 100%; background: gray" align="center">
					<div class="page">
						<xsl:choose>
							<!--<xsl:when test="/step/@change='avatar'">
								<xsl:call-template name="head"/>
							</xsl:when>starts-with( $questID, concat( '/m8/', substring($fact,1,1), '/', $fact ) )-->
							<xsl:when test="$quest != 'system'">
								<xsl:apply-templates select="m8:path( $fact, 'index')"/>
							</xsl:when>
							<xsl:when test="not($author)">
								<!--/value/*/@avatar='m8data' and /value/map/text()-->
								<!--<xsl:if test="/*/*/@referer">
									<div style="float: right; margin: 1em">
										<a href="{/*/*/@referer}">назад</a>
									</div>
									<br style="clear: both"/>								
								</xsl:if>-->
								<xsl:call-template name="authorDef"/>
							</xsl:when>
							<xsl:otherwise>
								<!--<div style="float: right; margin: 1em">
									<a href="{$objectID}/">назад</a>
								</div>-->
								<br style="clear: both"/>
								<div style="align: center; margin: 1em">
									<xsl:for-each select="document('/avatar.xml')/*/*">
										<div>
											<xsl:choose>
												<xsl:when test="@id=$avatar">
													<a href="/">
														<xsl:value-of select="@title|@id"/>
													</a>
												</xsl:when>
												<xsl:otherwise>
													<a href="/{@id}/?group=">
														<xsl:value-of select="@title"/>
														<xsl:if test="not(@title)">
															<xsl:value-of select="@id"/>
														</xsl:if>
													</a>
												</xsl:otherwise>
											</xsl:choose>
										</div>
									</xsl:for-each>
								</div>
								<br/>
								<!--<div style="position: absolute; bottom: 25px; right: 30px">
									<a href="?control=1">control</a>
								</div>	-->
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
				<!--	<script type="text/javascript">
$(document).ready(function(){
    $("form").change(function() {
        select();
    });
});
			</script>//-->
			</body>
		</html>
	</xsl:template>
	<xsl:template name="control">
		<xsl:message terminate="no">interface match="/"</xsl:message>
		<html>
			<head>
				<title>
					<xsl:choose>
						<xsl:when test="/*/*[@error]">!!!!!!!! <xsl:value-of select="/*/@control"/> ERROR !!!!!!!!</xsl:when>
						<xsl:otherwise>Ok <xsl:value-of select="/*/@dirs"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="/*/@control"/>
						</xsl:otherwise>
					</xsl:choose>
				</title>
				<xsl:if test="*/@revolution">
					<script type="text/javascript">setTimeout(function() {location.reload()}, <xsl:value-of select="*/@revolution"/>000);
				</script>
				</xsl:if>
				<!--<xsl:choose>
					<xsl:when test="*/@revolution"><meta http-equiv="refresh" content="10;http://www.m8data.com/m8/$/reg.pl?control=1&amp;action=1&amp;claen=1&amp;revolution=1"/></xsl:when>
					<xsl:otherwise><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/></xsl:otherwise>
				</xsl:choose>-->
				<!--
				-->
				<style>a {
				color: blue;
				 font-size: 0.8em;
				text-decoration: none;
				}
				a:active {
					color: blue;
					text-decoration: none;
				}
				a:link {
					color: blue;
					text-decoration: none;
				}
				a:visited {
					color: blue;
					text-decoration: none;
				}
				a:focus {
					color: blue;
					text-decoration: none;
				}
				a:hover {
					color: blue;
					text-decoration: none;
				}</style>
			</head>
			<body style="padding: 0; margin: 0; font-family: Verdana, Arial, Helvetica, sans-serif;">
				<!--  onload="setTimeout(window.location.reload(), 10)"  onload="this.location.reload()" font-size: 0.9em-->
				<div style="position: absolute; bottom: 5px; left: 10px">
					<a href="/system/?control=1&amp;serverTranslate=1">
						<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@serverTranslate">;background: #BFB</xsl:if></xsl:attribute>
						<xsl:text>на сервере</xsl:text>
					</a>
					<xsl:text> | </xsl:text>
					<a href="/system/?control=1&amp;serverTranslate=">
						<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="not(*/@serverTranslate)">;background: #EEE</xsl:if></xsl:attribute>
						<xsl:text>на клиенте</xsl:text>
					</a>
				</div>
				<div style="position: absolute; bottom: 5px; right: 10px">
					<a href="/system/?control=start">start</a> | <a href="/system/?control=dry">dry</a> | <a href="/system/?control=dry2">dry2</a>
					<!--<a href="/?control=tall">
						<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="/report/@control='tall'">;background: #FCC</xsl:if></xsl:attribute>
						<xsl:text>Длинный</xsl:text> 
					</a>
					<xsl:text> | </xsl:text>
					<a href="/?control=fat">
						<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="/report/@control='fat'">;background: #FCC</xsl:if></xsl:attribute>
						<xsl:text>Толстый</xsl:text>
					</a>-->
				</div>
				<div style="float: left;">
					<!--<b>
						<xsl:value-of select="/*/@control"/>
					</b>: -->
					<div style="position: absolute; bottom: 5px; left: 45%">
						<a href="/system/?tempAvatar=&amp;control=1">xml</a>
					</div>
					<a href="/system/?control=1&amp;emulationControl=1">
						<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@emulationControl">;background: #BFB</xsl:if></xsl:attribute>
						<xsl:text>без записи</xsl:text>
					</a>
					<xsl:text> | </xsl:text>
					<a href="/system/?control=1&amp;emulationControl=">
						<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="not( */@emulationControl )">;background: #EEE</xsl:if></xsl:attribute>
						<xsl:text>с записью</xsl:text>
					</a>
				</div>
				<div style="float: right; padding-right: 5px">
					<span style="font-size: .8em">удалить</span>
					<xsl:text> </xsl:text>
					<a href="/system/?control=1&amp;del=1">индекс</a> |
					<a href="/system/?control=1&amp;del=2">базу</a> |
					<a href="/system/?control=1&amp;del=3">все</a>
					<!-- |
					<a href="/?control=1&amp;del=3">целиком</a> | 
					<a href="{$regScript}?proc1=exit" style="color: red">выйти</a>-->
				</div>
				<div style="text-align: center">
					<span>
						<!--<a href="{$controlScript}">обновить</a>
						<xsl:text> </xsl:text>-->
						<a href="/system/?control=1">обновить</a>
						<xsl:text> | </xsl:text>
						<a href="/system/?control=1&amp;revolution=4">
							<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@revolution=4">;background: #FCC</xsl:if></xsl:attribute>
							<xsl:text>4</xsl:text>
						</a>
						<xsl:text> </xsl:text>
						<a href="/system/?control=1&amp;revolution=16">
							<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@revolution=16">;background: #FCC</xsl:if></xsl:attribute>
							<xsl:text>16</xsl:text>
						</a>
						<xsl:text> </xsl:text>
						<a href="/system/?control=1&amp;revolution=65536">
							<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@revolution=65536">;background: #FCC</xsl:if></xsl:attribute>
						18ч
						</a>
					</span>
				</div>
				<br clear="all"/>
				<xsl:apply-templates select="*" mode="start"/>
				<!--	//-->
			</body>
		</html>
	</xsl:template>
	<!--		<xsl:if test="document('/m8')"></xsl:if>

Внимение! В шаблонах построения JSON после знаков переноса "\" не должно быть других символов включая пробелы и табуляции		

	 -->
	<xsl:template match="null" mode="start">
		 данные отсутствуют
	 
	 </xsl:template>
	<xsl:template match="report" mode="start">
		<div style="margin: 0 1em;  font-size: 9pt">
			<table width="100%">
				<tr>
					<td>Запросов: <xsl:value-of select="@dirs"/>
					</td>
					<td>Рун: <xsl:value-of select="count(/*/dir[@plan='rune'])"/>
					</td>
					<td>Ошибок: <xsl:value-of select="count(/*/dir[@error])"/>
					</td>
					<td title="{@cutoff}">
						<xsl:value-of select="@cutoff2"/>
					</td>
				</tr>
				<tr>
					<td>Директорий: <xsl:value-of select="count(/*/dir)"/>
					</td>
					<td>Нод: <xsl:value-of select="count(/*/dir[@plan='node'])"/>
					</td>
					<td>Архив: <xsl:value-of select="@archive"/>
					</td>
				</tr>
			</table>
			<xsl:if test="/*/die">
				<div style="padding: 1em">
					<div>Удаленное:</div>
					<xsl:for-each select="/*/die">
						<div>
							<a href="{@id}">
								<xsl:value-of select="@id"/>
							</a>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
			<xsl:if test="/*/file">
				<div style="padding: 1em">
					<div>Лишнее:</div>
					<xsl:for-each select="/*/file">
						<div>
							<a href="{@id}">
								<xsl:value-of select="@id"/>
							</a>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
			<xsl:if test="/*/need">
				<div style="padding: 1em">
					<div>Недостает:</div>
					<xsl:for-each select="/*/need">
						<div>
							<a href="{@id}">
								<xsl:value-of select="@id"/>
							</a>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
			<!--<div>На валидацию: <xsl:value-of select="@tovalid"/></div>-->
			<table cellspacing="0" border="1" width="50%">
				<tr align="center" style="font-size: x-small">
					<td>value</td>
					<!--<td>mount</td>
					<td>shine</td>
					<td>relation</td>-->
					<td>index</td>
					<td>validate</td>
					<!--<td>1</td>
					<td>2</td>
					<td>3</td>
					<td>0</td>-->
				</tr>
				<!-- -->
				<xsl:for-each select="/*/dir">
					<!-- [@level=0]-->
					<xsl:sort select="@metter"/>
					<tr>
						<td>
							<xsl:comment>Вывод колонки Id сущности</xsl:comment>
							<xsl:apply-templates select="document(concat(@metter, '/value.xml'))/*/@id" mode="styleID"/>
							<xsl:if test="@new">
								<span style="color:red; font-size: x-small" title="{@new}"> new</span>
							</xsl:if>
						</td>
						<!--<td>
							<xsl:if test="(@p0='n1' or @p0='n0') and document(@id)/*/@activate">
								<xsl:apply-templates select="document(@id)/*/@activate" mode="styleID"/>
							</xsl:if>
						</td>
						<td>
							<xsl:if test="(@p0='n1' or @p0='n0') and document(@id)/*/@shine">
								<xsl:apply-templates select="document(@id)/*/@shine" mode="styleID"/>
							</xsl:if>
						</td>
						<td>
							<xsl:if test="1">
								<xsl:apply-templates select="document(@id)/*/@relation" mode="styleID"/>
							</xsl:if>
						</td>-->
						<td>
							<a href="{@id}">
								<xsl:value-of select="@id"/>
							</a>
						</td>
						<td>
							<xsl:if test="@fileShema">
								<!--document(@id)/*[name()='index'] -->
								<xsl:apply-templates select="." mode="aspect"/>
							</xsl:if>
						</td>
						<!--<td>
							<xsl:comment>Вывод колонки подлежащего</xsl:comment>
							<xsl:if test="@p0='n1'">
								<xsl:apply-templates select="document(concat(@metter, '/value.xml'))/*/a1" mode="styleID"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="/*/@control = 'fat'">
									<xsl:apply-templates select="/*/dir[@p0=current()/@p0][@p1=current()/@p1][@p2=1]" mode="aspect"/>
								</xsl:when>
							</xsl:choose>
						</td>
						<td>
							<xsl:if test="@p0='n1'">
								<xsl:apply-templates select="document(concat(@id, '/value.xml'))/*/a2" mode="styleID"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="/*/@control = 'fat'">
									<xsl:apply-templates select="/*/dir[@p0=current()/@p0][@p1=current()/@p1][@p2=2]" mode="aspect"/>
								</xsl:when>
								<xsl:when test="@plan = 'rune'"/>
							</xsl:choose>
						</td>
						<td>
							<xsl:if test="@p0='n1'">
								<xsl:apply-templates select="document(concat(@id, '/value.xml'))/*/a3" mode="styleID"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="/*/@control = 'fat'">
									<xsl:apply-templates select="/*/dir[@p0=current()/@p0][@p1=current()/@p1][@p2=3]" mode="aspect"/>
								</xsl:when>
								<xsl:when test="@mark">
									<xsl:value-of select="@mark"/>
								</xsl:when>
							</xsl:choose>
						</td>
						<td>
							<xsl:choose>
								<xsl:when test="/*/@control = 'fat'">
									<xsl:apply-templates select="/*/dir[@p0=current()/@p0][@p1=current()/@p1][@p2=0]" mode="aspect"/>
								</xsl:when>
								<xsl:when test="@mark">
									<xsl:value-of select="@mark"/>
								</xsl:when>
							</xsl:choose>
						</td>-->
					</tr>
				</xsl:for-each>
				<!--<-->
			</table>
		</div>
	</xsl:template>
	<!--


	-->
	<xsl:template match="*|@*" mode="styleID">
		<a href="{.}/value.xml">
			<xsl:attribute name="style"><xsl:text>background: #</xsl:text><xsl:choose><xsl:when test="substring(., 5, 2) = 'n0' and 100 > substring(., 8)">aaa</xsl:when><xsl:when test="substring(., 5, 2) = 'n0'"><xsl:value-of select="substring(translate(., 'ghiklmnopqrstvwxyz', 'aaabbbcccdddeeefff'),8, 3)"/><xsl:text>; color: white</xsl:text></xsl:when><xsl:when test="substring(., 5, 2) = 'n1'"><xsl:value-of select="substring(., 8, 3)"/><xsl:text>; color: white</xsl:text></xsl:when><xsl:otherwise><xsl:value-of select="substring(translate(., 'ghiklmnopqrstvwxyz', 'aaabbbcccdddeeefff'),8,3)"/></xsl:otherwise></xsl:choose></xsl:attribute>
			<xsl:value-of select="."/>
		</a>
		<xsl:text> </xsl:text>
		<!--//-->
	</xsl:template>
	<!--

[not(@p5)]
	-->
	<xsl:template match="dir" mode="aspect">
		<span style="background: gray; color: white">
			<!--<a href="{@id}/{@fileShema}.xml" style="color:white">
				<xsl:value-of select="@level"/>
			</a>
			<xsl:text> </xsl:text>-->
			<xsl:choose>
				<xsl:when test="@error">
					<a style="color: red" href="{@id}/{@fileShema}.xsd" title="{@error}">V</a>
				</xsl:when>
				<xsl:otherwise>
					<a style="color: white" href="{@id}/{@fileShema}.xsd">V</a>
				</xsl:otherwise>
			</xsl:choose>
		</span>
		<xsl:text> </xsl:text>
	</xsl:template>
	<!--

-->
	<xsl:template match="dir[@p5]" mode="aspect">
		<a href="{@id}/{@fileShema}.xml">S</a>
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="@error">
				<a href="{@id}/{@fileShema}.xsd" style="background:  #FAA" title="{@error}">V</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="{@id}/{@fileShema}.xsd">V</a>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
	</xsl:template>
				<!--

	-->
	<xsl:template name="authorDef">
		<div style="float: right; margin: 1em">
			<a href="{$script}/">назад</a>
		</div>
		<xsl:if test="/*/*/@referer"> </xsl:if>
		<div style="text-align: center; padding: 2em; color: red">
			<xsl:value-of select="@history"/>
		</div>
		<script type="text/javascript">
function getCookie(name) {
  var matches = document.cookie.match(new RegExp(
    "(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, '\\$1') + "=([^;]*)"
  ));
  return matches ? decodeURIComponent(matches[1]) : undefined;
}			
regMessage = getCookie('last');
			if (regMessage){alert(regMessage)}</script>
		<table width="100%">
			<tr>
				<td valign="top" align="center">
					<h1>Вход на сайт</h1>
					<div>Укажите ваши имя и пароль на сайте</div>
					<form style="padding: 2em" action="{$script}" method="get">
						<input type="hidden" name="author"/>
						<xsl:if test="@history='no user'">
							<div style="color: red">Пароль или имя указаны не верно</div>
						</xsl:if>
					Юзер :<input type="text" name="login" value="{$login}"/>
						<!--  formaction="{$script}"-->
						<br/>
					Пароль: <input type="password" name="password"/>
						<br/>
						<button type="submit">Go!</button>
					</form>
				</td>
				<!--<xsl:if test="$avatar='system'"></xsl:if>//-->
				<td valign="top" align="center">
					<h1>Регистрация на сайте</h1>
					<form method="get" id="rs_first">
						<input type="hidden" name="author"/>
						<xsl:if test="@history='busy'">
							<div style="color: red">имя уже занято </div>
							<!-- -->
						</xsl:if>
					Имя<input type="text" name="new_author" value="{$new_author}"/>
						<!---->
						<br/>(без пробелов латиницей)                                        <br/>
						<xsl:if test="@history and (@history='bad_retype' or @history='no_password')">
							<div style="color: red">
								<xsl:choose>
									<xsl:when test="@history='bad_retype'">Повторение пароля не совпало. Введите заново.</xsl:when>
									<xsl:when test="@history='no_password'">Задайте пароль</xsl:when>
								</xsl:choose>
							</div>
						</xsl:if>
					Пароль<input type="password" name="new_password"/>
						<br/>
					Повтор<input type="password" name="new_password2"/>
						<br/>
						<button type="submit" formaction="{$script}">Регистрация</button>
						<br/>
					</form>
				</td>
			</tr>
		</table>
	</xsl:template>
			<!--

	-->
	<xsl:template match="index">
	<div style="text-align: left; padding: 1em">
		<div style="float: right; background: #FDC; padding: 1em; margin: .5em">
			<xsl:for-each select="$temp/@*">
				<div><b><xsl:value-of select="name()"/></b>: <xsl:value-of select="."/></div>
			</xsl:for-each>
		</div>
		<a href="/system/">m8</a>
		<div style="padding-left: 2em">
		<h1><a href="{$questID}" style="color: black"><xsl:value-of select="$fact"/></a></h1>
		<xsl:for-each select="*">
			<div style="padding-left: 2em">
				<h2><xsl:value-of select="name()"/></h2>
				<xsl:for-each select="*">
					<xsl:variable name="role" select="name()"/>
					<xsl:variable name="curFile" select="@file"/>
					<div style="padding-left: 2em">
						<h3><xsl:value-of select="name()"/><xsl:text> </xsl:text><sup><a href="/m8/{substring($fact,1,1)}/{$fact}/{@file}.xml">xml</a></sup></h3>
						<xsl:for-each select="document(concat( '/m8/', substring($fact,1,1), '/', $fact, '/', @file, '.xml' ) )/*/*">
							<xsl:variable name="curAuthor" select="name()"/>
							<div style="padding-left: 2em">
								<h4>
									<xsl:if test="$curAuthor = $author"><xsl:attribute name="style"><xsl:text>background: #FBB</xsl:text></xsl:attribute></xsl:if>
								author: <xsl:value-of select="name()"/></h4>
								<xsl:for-each select="*/*">
									<xsl:variable name="curQuest" select="name()"/>
									<div style="padding-left: 2em">
										<h4>
										<xsl:if test="$curQuest = $quest"><xsl:attribute name="style"><xsl:text>background: #BBF</xsl:text></xsl:attribute></xsl:if>
										<xsl:choose>
											<xsl:when test="$role = 'role1'">
												<xsl:choose>
													<!--<xsl:when test="$fact=$curQuest"><span style="font-size: 1.6em"><xsl:value-of select="name()"/></span></xsl:when>-->
													<xsl:when test="$quest=$curQuest and $curAuthor=$author"><span style="font-size: 1.8em"><a href="/m8/{substring($fact,1,1)}/{$fact}/{$curAuthor}/{$avatar}/{$curQuest}"><i><xsl:value-of select="name()"/></i></a></span></xsl:when>
													<xsl:otherwise><a href="/m8/{substring($fact,1,1)}/{$fact}/{$curAuthor}/{$avatar}/{$curQuest}"><xsl:value-of select="name()"/></a></xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise><xsl:value-of select="name()"/></xsl:otherwise>
										</xsl:choose>
										<xsl:text> </xsl:text>
										<sup><a href="/m8/{substring($fact,1,1)}/{$fact}/{$curAuthor}/{$avatar}/{$curQuest}/{$curFile}.xml">xml</a></sup>
										</h4>
									</div>
								</xsl:for-each>
							</div>
						</xsl:for-each>
					</div>
				</xsl:for-each>
			
			</div>
		
		</xsl:for-each>
	
	</div>
	</div>
	</xsl:template>
				<!--

	-->
	
</xsl:stylesheet>
