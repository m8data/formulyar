<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="no"/>
	<!--<xsl:param name="script" select="'/m8/$/step.pl'"/>-->
	<xsl:param name="regScript" select="'/$/reg.pl'"/>
	<xsl:param name="controlScript" select="concat($regScript, '?control=', /*/@control)"/>
	<!--

	 -->
	<xsl:template match="/">
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
				<a href="/?control={/*/@control}&amp;locationType=html">
				<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@locationType='html'">;background: #FCC</xsl:if></xsl:attribute>
				<xsl:text>на сервере</xsl:text></a>
				<xsl:text> | </xsl:text>
				<a href="/?control={/*/@control}&amp;locationType=xml">
				<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@locationType='xml'">;background: #FCC</xsl:if></xsl:attribute>
				<xsl:text>на клиенте</xsl:text>
				</a>
				</div>
				
				<div style="position: absolute; bottom: 5px; right: 10px">
					<a href="/?control=tall">
						<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="/report/@control='tall'">;background: #FCC</xsl:if></xsl:attribute>
						<xsl:text>Длинный</xsl:text> 
					</a>
					<xsl:text> | </xsl:text>
					<a href="/?control=fat">
						<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="/report/@control='fat'">;background: #FCC</xsl:if></xsl:attribute>
						<xsl:text>Толстый</xsl:text>
					</a>
				</div>
			

				<div style="float: left;">
					<!--<b>
						<xsl:value-of select="/*/@control"/>
					</b>: -->
				
				<div style="position: absolute; bottom: 5px; left: 45%">
				<a href="/?control={/*/@control}&amp;out=xml">xml</a>
				</div>
				
				<a href="/?control={/*/@control}&amp;clean=1">
				<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@clean=1">;background: #FCC</xsl:if></xsl:attribute>
				<xsl:text>с чисткой</xsl:text></a>
				<xsl:text> | </xsl:text>
				<a href="/?control={/*/@control}&amp;clean=0">
				<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@clean=0">;background: #FCC</xsl:if></xsl:attribute>
				<xsl:text>без чистки</xsl:text>
				</a>
				</div>
				<div style="float: right; padding-right: 5px">
					<a href="/?control={/*/@control}&amp;del=1">обнулить</a> |
					<a href="/?control={/*/@control}&amp;del=2">c журналом</a> |
					<a href="/?control={/*/@control}&amp;del=3">целиком</a><!-- | 
					<a href="{$regScript}?proc1=exit" style="color: red">выйти</a>-->
				</div>
				<div style="text-align: center">
					<span>
						
						<!--<a href="{$controlScript}">обновить</a>
						<xsl:text> </xsl:text>-->
						<a href="/?control={/*/@control}">обновить</a>
						<xsl:text> | </xsl:text>
						<a href="/?control={/*/@control}&amp;revolution=4">
						<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@revolution=4">;background: #FCC</xsl:if></xsl:attribute>
						<xsl:text>4</xsl:text>
						</a>
						<xsl:text> </xsl:text>
						<a href="/?control={/*/@control}&amp;revolution=16">
						<xsl:attribute name="style"><xsl:text> padding: .2em</xsl:text><xsl:if test="*/@revolution=16">;background: #FCC</xsl:if></xsl:attribute>
						<xsl:text>16</xsl:text>
						</a>
						<xsl:text> </xsl:text>
						<a href="/?control={/*/@control}&amp;revolution=65536">
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
				<xsl:for-each select="/*/dir"><!-- [@level=0]-->
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
								<a href="{@id}"><xsl:value-of select="@id"/> </a>
						</td>
						<td>
							<xsl:if test="@fileShema"><!--document(@id)/*[name()='index'] -->
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
	</xsl:template><!--

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
илья утепление стен 427176  8 920 6378176

	-->
</xsl:stylesheet>
