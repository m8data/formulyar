<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common" xmlns:m8="http://m8data.com">
	<xsl:output method="html" version="1.0" encoding="UTF-8"/>
	<xsl:include href="system_form.xsl"/>
	<xsl:include href="system_head.xsl"/>
	<!--


	-->
	<xsl:template name="Head2">
		<script src="{$start/@prefix}p/formulyar/js/jquery.min-1.9.0.js"/>
		<script>var source = "";</script>
		<!-- по какой-то причине, если не втавить этот тэг, то предыдущий открывающий тег скрипта не закроется //
		<script src="{$start/@prefix}system/a/js/xalio.js"/>-->
		<script>var source2 = "";</script>
	</xsl:template>
	<xsl:template name="TitleAndMisk">
		<title>
			<xsl:value-of select="$start/@avatar"/>: административный раздел</title>
	</xsl:template>
	<!--	


	-->
	<xsl:template name="startBody">
		<xsl:call-template name="footer"/>
		<!--<div style="position: fixed; bottom: 5px; left: 5px; z-index: 1">
			<a href="{$start/@prefix}teplotn/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">calculator</a>
			<xsl:text> | </xsl:text>
			<a href="{$start/@prefix}system/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">sys</a>
			<xsl:text> | </xsl:text>
			<a href="{$start/@prefix}xalio/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">refresh</a>
			<xsl:text> | </xsl:text>
			<a href="{$start/@prefix}m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}/port.xml">xml</a>
		</div>
		<div style="position: fixed; bottom: 5px; right: 5px; color: gray; z-index: 1">
			<span title="аватар"><xsl:value-of select="$avatar"/></span>
			<xsl:text> |  </xsl:text>	
			<xsl:value-of select="$localtime"/>
			<xsl:if test="$user != 'guest' ">
				<xsl:text> |  </xsl:text>
				<xsl:value-of select="$user"/>
				<xsl:text> |  </xsl:text>
				<a href="{$start/@prefix}m8/?logout=true" style="color: red">выйти</a>
			</xsl:if>
		</div>-->
		<xsl:apply-templates select="." mode="start"/>
	</xsl:template>
	<!--

	-->
	<xsl:template match="port|terminal" mode="start">
		<xsl:choose>
			<xsl:when test=" $fact = 'n' ">
				<br/>
				<br/>
				<br/>
			</xsl:when>
			<xsl:otherwise>
				<div>
					<xsl:choose>
						<xsl:when test="m8:path( $fact, 'index' )/role">
							<xsl:message terminate="no">Зеленая карта</xsl:message>
							<div style="background: #EFD; padding: 1em">
								<xsl:message> ^ ^ ^ ^ ^ - Зона ссылок наверх - ^ ^ ^ ^ ^ </xsl:message>
								<table style="font-size: 1em;" width="100%">
									<tr>
										<td width="30%" valign="top">
											<xsl:for-each select="exsl:node-set($parent)/*">
												<xsl:if test="position()!=1">
													<xsl:text> / </xsl:text>
												</xsl:if>
												<xsl:variable name="preceding-sibling" select="name( preceding-sibling::*[1] )"/>
												<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( name() ) }" style="{m8:color( name() )}" title="{m8:holder( name() )}">
													<xsl:apply-templates select="." mode="simpleName"/>
												</a>
											</xsl:for-each>
										</td>
										<td width="40%" align="center" style="color: #444" valign="top">
											<div style="padding-bottom: .4em">
												<span style="font-size: 1.2em; {m8:color( $fact )}" title="{m8:holder( $fact )}">
													<xsl:text>нечто </xsl:text>
													<xsl:value-of select="$fact"/>
												</span>
											</div>
											<xsl:if test="$parentName != $typeName">
												<!-- and $parentName != 'n'-->
												<xsl:text>  c типом </xsl:text>
												<a href="{m8:root( $typeName )}" style="{m8:color( $typeName)}" title="{m8:holder( $typeName )}">
													<b>
														<xsl:apply-templates select="exsl:node-set($parent)/*[last()]/*" mode="simpleName"/>
													</b>
												</a>
												<!--<xsl:text>  в квесте </xsl:text>
												<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $quest )}" style="{m8:color( $quest)}" title="{m8:holder( $quest )}">
													<xsl:apply-templates select="@quest" mode="simpleName"/>
												</a>-->
											</xsl:if>
											<xsl:if test="$modifier != 'n'">
												<span> в модификации </span>
												<a href="{m8:root( $modifier )}" style="{m8:color( $modifier )}" title="{m8:holder( $modifier )}">
													<xsl:apply-templates select="$start/@modifier" mode="simpleName"/>
												</a>
											</xsl:if>
										</td>
										<!-- n500 r i n n500 -->
										<td width="30%" align="right" valign="top">
											<xsl:choose>
												<xsl:when test="$startPort/r or 1">
													<xsl:variable name="siblings">
														<xsl:for-each select="m8:path( $typeName, 'index' )/object/*">
															<xsl:sort select="@time"/>
															<xsl:copy/>
														</xsl:for-each>
													</xsl:variable>
													<!--<div>typeName: <xsl:value-of select="$typeName"/></div>
													<xsl:apply-templates select="exsl:node-set($siblings)/*" mode="serialize"/>-->
													<xsl:if test="exsl:node-set($siblings)/*[name()=$fact]/preceding-sibling::*">
														<xsl:variable name="predName" select="name(exsl:node-set($siblings)/*[name()=$fact]/preceding-sibling::*[1])"/>
														<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $predName )}" style="{m8:color( $predName )}" title="{m8:holder( $predName )}">
															<xsl:apply-templates select="exsl:node-set($siblings)/*[name()=$fact]/preceding-sibling::*[1]" mode="simpleName"/>&#9668;</a>
													</xsl:if>
													<span>&#160;&#160;X&#160;&#160;</span>
													<xsl:if test="exsl:node-set($siblings)/*[name()=$fact]/following-sibling::*">
														<xsl:variable name="nextName" select="name(exsl:node-set($siblings)/*[name()=$fact]/following-sibling::*[1])"/>
														<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $nextName )}" style="{m8:color( $nextName )}" title="{m8:holder( $nextName )}">&#9658;<xsl:apply-templates select="exsl:node-set($siblings)/*[name()=$fact]/following-sibling::*[1]" mode="simpleName"/>
														</a>
													</xsl:if>
												</xsl:when>
												<xsl:otherwise>
													<a href="{$start/@prefix}a/{$ctrl}/">X</a>
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</tr>
								</table>
								<xsl:message> ^ ^ ^ ^ ^ - Зона ссылок наверх (END) - ^ ^ ^ ^ ^ </xsl:message>
								<br/>
								<xsl:call-template name="quest_port"/>
								<br style="clear: both"/>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>Красная карта</xsl:message>
							<div style="margin: 2em; padding: 1em; background: #FED">
								<div style="float: right">
									<a href="{$start/@prefix}a/{$ctrl}/">X</a>
								</div>
								<br style="clear: both"/>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$modifier = 'n'">
			<div style="padding: 3em" id="linkDownZone">
				<xsl:message> v v v v v - Зона ссылок вниз - v v v v v </xsl:message>
				<table width="100%" style="font-size: .9em;">
					<tr>
						<td align="center" valign="top" width="30%">
							<xsl:if test="m8:path( $fact,  'index' )/director/*">
								<b style="color: #555">Состав	
							</b>
								<xsl:for-each select="m8:path( $fact, 'index' )/director/*[name()!='n']">
									<xsl:sort select="@time"/>
									<xsl:if test="m8:leader( name() )!=$fact">
										<div style="padding: .2em">
											<xsl:value-of select="position()"/>
											<xsl:text>. </xsl:text>
											<a href="{ m8:root( name() )}" style="{m8:color( name() )}" title="{m8:holder( name() )}">
												<xsl:apply-templates select="m8:port( name() )/r/*" mode="simpleName"/>
												<xsl:text> :: </xsl:text>
												<xsl:apply-templates select="." mode="simpleName"/>
											</a>
										</div>
									</xsl:if>
								</xsl:for-each>
							</xsl:if>
						</td>
						<td align="center" valign="top" width="40%">
							<xsl:if test="m8:path( $fact,  'index' )/object/*">
								<b>Экземпляры <!--"<xsl:apply-templates select="$start" mode="titleWord"/>"-->
								</b>
								<div style="padding: 1em">
									<xsl:for-each select="m8:path( $fact, 'index' )/object/*">
										<xsl:sort select="@time"/>
										<xsl:if test="m8:director( name() ) = $fact">
											<div style="font-size: 1.4em; padding: .1em">
												<a href="{ m8:root( name() )}" style="{m8:color( name() )}" title="{m8:holder( name() )}">
													<xsl:apply-templates select="." mode="simpleName"/>
												</a>
											</div>
										</xsl:if>
									</xsl:for-each>
								</div>
							</xsl:if>
						</td>
						<td align="center" valign="top" width="30%">
							<xsl:if test="m8:path( $fact,  'index' )/object/*">
								<div style="display: normal">
									<b style="color: #555">Послушники</b>
									<div style="padding: .2em">
										<xsl:for-each select="m8:path( $fact, 'index' )/object/*">
											<xsl:sort select="@time"/>
											<xsl:variable name="position" select="position()"/>
											<xsl:if test="m8:director( name() ) != $fact">
												<div style="font-size: 1.2em; padding: .1em">
													<a href="{ m8:root( name() )}" style="{m8:color( name() )}" title="{m8:holder( name() )}">
														<xsl:value-of select="$position"/>
														<xsl:text>. </xsl:text>
														<xsl:apply-templates select="." mode="simpleName"/>
													</a>
												</div>
											</xsl:if>
										</xsl:for-each>
									</div>
								</div>
								<br/>
								<br/>
								<br/>
								<br/>
							</xsl:if>
						</td>
					</tr>
				</table>
				<xsl:message> v v v v v - Зона ссылок вниз (END) - v v v v v </xsl:message>
			</div>
		</xsl:if>
		<div style="color: #777">
			<xsl:message>= = = = = = = - Зона упоминаний - = = = = = =</xsl:message>
			<xsl:if test="m8:path( $fact, 'quest' )/*">
				<br/>
				<div>
					<b>модификатор</b>
					<div style="padding: .2em">
						<xsl:for-each select="m8:path( $fact, 'quest' )/*[name()!=$fact]">
							<xsl:sort select="@time"/>
							<div>
								<a href="{m8:action( name(), $fact )}" style="{ m8:color( name() )}" title="{ m8:holder( name() ) }">
									<xsl:apply-templates select="." mode="simpleName"/>
								</a>
							</div>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="m8:path( $fact, 'role1' )/*[name()!='n'] and $modifier = 'n' ">
				<br/>
				<div>
					<b>модификация</b>
					<div style="padding: .2em">
						<xsl:for-each select="m8:path( $fact, 'role1' )/*[name()!='n']">
							<xsl:sort select="@time"/>
							<div>
								<a href="{m8:action( $fact, name() )}" style="{ m8:color( name() )}" title="{ m8:holder( name() ) }">
									<xsl:apply-templates select="." mode="simpleName"/>
								</a>
							</div>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:message>= = = = = = = - Зона упоминаний (END) - = = = = = =</xsl:message>
		</div>
		<xsl:message> 
									@@@@@ - Зона генерации нового - @@@@@
				</xsl:message>
		<!--<div style="position: fixed; bottom: 50px; left: 50px; font-size: 2em; background-color: green; opacity: 0.5; padding: 1em; padding-bottom: 0; border-radius: 2em; ">
			<form action="{$start/@prefix}a/{$ctrl}/{m8:dir( $fact )}/">
				<span style="font-size: 11pt; color: white">Добавить: </span>
				<input type="hidden" name="quest" value="{$fact}"/>
				<select name="a" onchange="this.form.submit()">
					<option/>
					<xsl:for-each select="m8:path( 'r', 'predicate_n' )/*/*">
						<option value="{name()}">
							<xsl:apply-templates select="." mode="titleWord"/>
						</option>
					</xsl:for-each>
				</select>
			</form>
		</div>-->
		<style version="text/css">
			#circle {
			position: fixed; 
	width: 64px;
	height: 64px;
	-moz-border-radius: 32px;
	-webkit-border-radius: 32px;
	border-radius: 32px;
	#border: 4px solid gray;
	opacity: 0.6;
	font-size: 2.4em;
	line-height: 186%;
	background: green;
}
#circle a {color: yellow; }
		</style>
		<a href="{m8:root( $fact )}/?a=" title="создать новый объект" style="color: white;">
			<span style="bottom: 64px; right: 64px; " id="circle">+</span>
		</a>
		<!--<div style="bottom: 70px; right: 165px; " id="circle">
			<a href="{$start/@prefix}a/{$ctrl}/{m8:dir( $fact )}/?a=" title="реплицировать внутрь" style="color: purple">&#9632;</a>
		</div>
		<div style="bottom: 70px; right: 70px; font-size: 4.7em; line-height: 64%;" id="circle">
			<a href="{$start/@prefix}a/{$ctrl}/?a=" title="реплицировать на свободу" style="color: red">&#9679;</a>
		</div>-->
		<xsl:message> newQuestName
			@@@@@ - Зона генерации нового (END) - @@@@@
		</xsl:message>
	</xsl:template>
	<!--


	-->
	<xsl:template name="quest_port">
		<xsl:variable name="predicatesThisNechto">
			<xsl:for-each select="m8:path( $startTypeName, 'index' )/object/*">
				<xsl:variable name="subjectName" select="name()"/>
				<xsl:for-each select="m8:path( $startTypeName, concat( 'object_', $subjectName ) )/*/*">
					<xsl:for-each select="m8:path( $subjectName, name(..), name(), 'port' )/*[name() != 'r' ]">
						<xsl:element name="{name()}">_</xsl:element>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="sorted_predicates">
			<xsl:for-each select="exsl:node-set($predicatesThisNechto)/*">
				<xsl:sort select="name()"/>
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="final_sort">
			<xsl:apply-templates select="exsl:node-set($sorted_predicates)/*[1]" mode="predicate_grouping_new"/>
		</xsl:variable>
		<table width="100%" style="font-size: 1em">
			<tr>
				<td align="center" valign="top">
					<xsl:message>!! Левая панель: значения порта !!</xsl:message>
					<div style="padding: 1em; margin: .5em">
						<!--<xsl:choose>
							<xsl:when test="$startIndex/*[name()!='subject']">-->
						<table>
							<xsl:for-each select="$startPort/*[name()!='r']">
								<xsl:sort select="name()"/>
								<xsl:variable name="pName" select="name()"/>
								<tr>
									<th valign="top" align="right">
										<a href="{ m8:root( $pName )}">
											<span style="font-size: .8em; color: black">
												<xsl:choose>
													<xsl:when test="$pName = 'i' ">имя</xsl:when>
													<xsl:when test="$pName = 'n' ">файл</xsl:when>
													<xsl:when test="$pName = 'd' ">описание</xsl:when>
													<xsl:when test="$pName=$fact">по умолчанию</xsl:when>
													<xsl:otherwise>
														<xsl:apply-templates select="." mode="simpleName"/>
													</xsl:otherwise>
												</xsl:choose>
											</span>
										</a>
									</th>
									<td valign="top" align="left">
										<!--<xsl:for-each select="*">-->
										<table>
											<tr>
												<td>
													<xsl:call-template name="editParamOfPort">
														<xsl:with-param name="predicateName" select="$pName"/>
														<xsl:with-param name="objectElement" select="$startPort"/>
													</xsl:call-template>
												</td>
												<td valign="top">
													<a href="{m8:root( name() )}">q</a>
												</td>
												<!--<xsl:if test="name()!='n'">-->
												<td valign="top">
													<!--<a href="{$startID}/?a0={name(*/*)}">x</a>-->
													<a href="{m8:action( $fact, $modifier )}&amp;a0={name(*/*)}">x</a>
												</td>
												<!--</xsl:if>-->
												<td valign="top">
													<xsl:if test="$adminMode">
														<sup>
															<a href="{$start/@prefix}m8/{substring(name(),1,1)}/{name()}/value.xml" style="color:gray; font-size:.6em">
																<xsl:value-of select="name()"/>
															</a>
														</sup>
													</xsl:if>
												</td>
											</tr>
										</table>
										<!--</xsl:for-each>-->
									</td>
								</tr>
							</xsl:for-each>
						</table>
						<xsl:variable name="holder" select="m8:holder( $fact )"/>
						<div style="background: #ded; padding: 1em; opacity: 0.75; position: absolute; left:0; bottom: 4em">
							<xsl:message>				-- Вывод пульта навигации --</xsl:message>
							<xsl:choose>
								<xsl:when test="$holder = $user">
									<xsl:variable name="newQuestName">
										<xsl:choose>
											<xsl:when test="exsl:node-set($parent)/*[last()-1]">
												<xsl:value-of select="name( exsl:node-set($parent)/*[last()-1] )"/>
											</xsl:when>
											<xsl:otherwise>n</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<table cellpadding="0">
										<tr>
											<td valign="top">
												<span style="font-size: .8em; color: brown">модификация</span>
											</td>
											<td valign="top">
												<form action="{m8:root( $fact )}" id="editParamOfPort">
													<select name="modifier" onchange="this.form.submit()">
														<option/>
														<xsl:for-each select="m8:path( $modifier, 'index' )/director/*[name()!=$fact]">
															<!--m8:director(  )-->
															<option value="{name()}">
																<!--<xsl:if test="name() = $modifier">
																	<xsl:attribute name="selected">selected</xsl:attribute>
																</xsl:if>-->
																<xsl:apply-templates select="." mode="simpleName"/>
															</option>
														</xsl:for-each>
													</select>
												</form>
											</td>
											<xsl:if test="$modifier != 'n' ">
												<td valign="top">
													<a href="{m8:action( $fact, m8:director( $modifier ) )}" title="to new Quest - { $newQuestName }">^</a>
												</td>
												<td valign="top">
													<a href="{m8:action( $fact )}" title="to new Quest - { $newQuestName }">x</a>
												</td>
											</xsl:if>
										</tr>
										<!--	</table>
									<table cellpadding="0">-->
										<!--<tr>
											<td valign="top">
												<span style="font-size: .8em; color: black">составление</span>
											</td>
											<td valign="top">
												<xsl:call-template name="editParamOfPort">
													<xsl:with-param name="predicateName" select="'modifier'"/>
													<xsl:with-param name="objectElement" select="m8:port( $director )"/>
													<xsl:with-param name="sourceValue">
														<option/>
														<xsl:copy-of select="m8:path( $director, 'index' )/object/*"/>
													</xsl:with-param> 
													<xsl:with-param name="action" select="m8:root( $fact )"/>
													<xsl:with-param name="hidden">
														<r>
															<xsl:value-of select="$typeName"/>
														</r>
													</xsl:with-param>
												</xsl:call-template>
											</td>
											<td valign="top">
												<a href="{m8:root( $fact )}/?r={$typeName}&amp;modifier={ $newQuestName }" title="to new Quest - { $newQuestName }">^</a>
											</td>
										</tr>-->
										<tr>
											<td valign="top">
												<span style="font-size: .8em; color: black">перемещение</span>
											</td>
											<td valign="top">
												<xsl:call-template name="editParamOfPort">
													<xsl:with-param name="predicateName" select="'modifier'"/>
													<xsl:with-param name="objectElement" select="m8:port( $director )"/>
													<!-- $typeName-->
													<xsl:with-param name="sourceValue">
														<option/>
														<xsl:copy-of select="m8:path( $director, 'index' )/object/*[name()!=$fact]"/>
													</xsl:with-param>
													<xsl:with-param name="hidden">
														<r>
															<xsl:value-of select="$typeName"/>
														</r>
														<xsl:if test="$director = $typeName">
															<object>
																<xsl:value-of select="$newQuestName"/>
															</object>
														</xsl:if>
													</xsl:with-param>
												</xsl:call-template>
											</td>
											<td valign="top">
												<xsl:if test="$director != 'n' ">
													<a title="to new Quest - { $newQuestName } COMMON">
														<xsl:attribute name="href">
															<xsl:value-of select="concat( m8:action( $fact, $newQuestName ), '&amp;r=', $typeName )"/>
															<xsl:if test="$director = $typeName">
																<xsl:text>&amp;object=</xsl:text><xsl:value-of select="$newQuestName"/>
															</xsl:if>
														</xsl:attribute>
														<xsl:text>^</xsl:text>
													</a>
												</xsl:if>
											</td>
											<td valign="top">&#160;
												<a href="{m8:root( $director )}/?a0={m8:triple( $fact )}">x</a>
												<!--&amp;a4={$parentName}-->
											</td>
										</tr>
										<tr>
											<td valign="top">
												<span style="font-size: .8em; color: black">разъединение</span>
											</td>
											<td valign="top">
												<xsl:call-template name="editParamOfPort">
													<xsl:with-param name="predicateName" select="'r'"/>
													<xsl:with-param name="objectElement" select="m8:port( m8:director( $typeName ) )"/>
													<!--<xsl:with-param name="action" select="m8:root( $fact )"/>-->
													<xsl:with-param name="sourceValue">
														<option/>
														<xsl:copy-of select="m8:path( $leader, 'index' )/object/*[name()!=$fact]"/><!--m8:director( -->
													</xsl:with-param>
													<xsl:with-param name="hidden">
														<modifier>
															<xsl:value-of select="$parentName"/>
														</modifier>
													</xsl:with-param>
												</xsl:call-template>
											</td>
											<xsl:variable name="typePosition" select="count( exsl:node-set($parent)/*[name(*)=$typeName][position()=1]/preceding-sibling::* )"/>
											<xsl:variable name="newTypeName">
												<xsl:choose>
													<xsl:when test="$typePosition">
														<xsl:value-of select="name( exsl:node-set($parent)/*[$typePosition]/* )"/>
													</xsl:when>
													<xsl:otherwise>n</xsl:otherwise>
												</xsl:choose>
											</xsl:variable>
											<td valign="top">
												<xsl:if test="$leader != 'n' ">
													<a href="{m8:action( $fact, $director )}&amp;r={$newTypeName}" title="to new typePosition - {$typePosition} / newTypeName - { $newTypeName }">^</a>
												</xsl:if>
											</td>
											<td valign="top">
												<xsl:if test="$leader != $director">
													<a href="{m8:action( $fact, $director )}&amp;r={$director}">x</a>
													<!--&amp;a4={$parentName}-->
												</xsl:if>
											</td>
										</tr>
									</table>
									<xsl:message>				-- Вывод пульта навигации (END) --
											</xsl:message>
									<!--<a href="{m8:root($parentName)}/?a0={name($parentPort/r/*/*)}&amp;a4={$parentName}" style="color: #222">удаление</a>-->
								</xsl:when>
								<xsl:otherwise>Владелец - <xsl:value-of select="$holder"/>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</td>
				<td align="center" valign="top">
					<div style="padding: 1em; ">
						<xsl:message>!! Правая панель: подсказки значений !!</xsl:message>
						<table cellpadding="3px">
							<xsl:for-each select="exsl:node-set($final_sort)/*">
								<xsl:sort select="@count" order="descending"/>
								<tr>
									<xsl:variable name="predicate" select="name()"/>
									<td valign="top" align="center">
										<a href="{$startID}/?a2={$predicate}" title="популярность: {@count}">
											<xsl:attribute name="style"><xsl:if test="@count=1"><xsl:text>font-size: .8em</xsl:text></xsl:if></xsl:attribute>
											<xsl:apply-templates select="." mode="simpleName"/>
										</a>
									</td>
								</tr>
							</xsl:for-each>
						</table>
						<div style="padding-bottom: .2em">Добавление свойства:</div>
						<xsl:if test="not( $startPort/*[name()='i'] )">
							<div style="padding-bottom: .2em">
								<a href="{m8:action( $fact, $modifier )}&amp;i=">имя</a>
							</div>
						</xsl:if>
						<xsl:if test="not( $startPort/*[name()='d'] )">
							<div style="padding-bottom: .2em">
								<a href="{m8:action( $fact, $modifier )}&amp;d=">описание</a>
							</div>
						</xsl:if>
						<xsl:if test="not( $startPort/*[name()='n'] )">
							<div style="padding-bottom: .4em">
								<a href="{m8:action( $fact, $modifier )}&amp;n=">структура</a>
							</div>
						</xsl:if>
						<xsl:message>
							START PORT:
							<xsl:apply-templates select="$startPort" mode="serialize"/>
						</xsl:message>
						<form action="{m8:root( $fact )}">
							<!--<input type="hidden" name="a1" value="{$fact}"/>-->
							<!--<input type="hidden" name="a4" value="n"/>-->
							<input type="hidden" name="modifier" value="{$modifier}"/>
							<input type="hidden" name="a3" value="r"/>
							<select name="a2" onchange="this.form.submit()">
								<option/>
								<!--<xsl:if test="not($startPort[name()='i'])">
									<option value="i">имя</option>
								</xsl:if>
								<xsl:if test="not($startPort[name()='d'])">
									<option value="d">описание</option>
								</xsl:if>
								<xsl:if test="not($startPort[name()='n'])">
									<option value="n">структура</option>
								</xsl:if>-->
								<xsl:if test="not( $factPort/*[name()=$fact] )">
									<option value="{$fact}">начало</option>
								</xsl:if>
								<xsl:for-each select="$types/@*">
									<xsl:sort select="name(.)"/>
									<!--<xsl:variable name="typeName">
										<xsl:value-of select="name( m8:path( name(), $avatar, 'terminal' )/* )"/>
									</xsl:variable>-->
									<xsl:if test="not( $startPort/*[name()=current()] )">
										<option value="{.}">
											<xsl:apply-templates select="." mode="simpleName"/>
										</option>
									</xsl:if>
								</xsl:for-each>
							</select>
						</form>
					</div>
				</td>
			</tr>
		</table>
		<!-- -->
	</xsl:template>
	<!--

	-->
	<xsl:template match="*" mode="predicate_grouping_new">
		<xsl:variable name="predicate" select="name()"/>
		<xsl:variable name="ref_with_this_predicate" select="../*[name() = $predicate]"/>
		<xsl:element name="{$predicate}">
			<xsl:attribute name="count"><xsl:value-of select="count($ref_with_this_predicate)"/></xsl:attribute>
			<xsl:text>_</xsl:text>
		</xsl:element>
		<xsl:apply-templates select="$ref_with_this_predicate[last()]/following-sibling::*[1]" mode="predicate_grouping_new"/>
	</xsl:template>
	<!--

	-->
	<xsl:template match="*" mode="predicate_grouping">
		<xsl:variable name="predicate" select="name()"/>
		<xsl:variable name="ref_with_this_predicate" select="../*[name() = $predicate]"/>
		<xsl:variable name="summ_sovp" select="../*[name() = $predicate]"/>
		<xsl:element name="{$predicate}">
			<xsl:attribute name="count"><xsl:value-of select="count($ref_with_this_predicate)"/></xsl:attribute>
			<xsl:for-each select="$ref_with_this_predicate">
				<xsl:for-each select="*">
					<xsl:sort select="name()"/>
					<xsl:element name="{name()}">
						<xsl:attribute name="sovpadenie"><xsl:value-of select="@sovpadenie"/></xsl:attribute>
					</xsl:element>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:element>
		<!--
    Входящий список в $sorted_plain отсортирован,
    поэтому в следующую группу отправляем элемент,
    идущий за последним элементом в текущей группе
    -->
		<xsl:apply-templates select="$ref_with_this_predicate[last()]/following-sibling::*[1]" mode="predicate_grouping"/>
	</xsl:template>
	<!--

	-->
	<xsl:template match="*" mode="value_grouping">
		<xsl:variable name="value" select="name()"/>
		<xsl:variable name="ref_with_this_value" select="../*[name() = $value]"/>
		<xsl:variable name="ref_with_this_value_sum_sovp" select="sum(../*[name() = $value]/@sovpadenie)"/>
		<xsl:element name="{$value}">
			<xsl:attribute name="count"><xsl:value-of select="count($ref_with_this_value)"/></xsl:attribute>
			<xsl:attribute name="sovpadenie"><xsl:value-of select="$ref_with_this_value_sum_sovp"/></xsl:attribute>
		</xsl:element>
		<xsl:apply-templates select="$ref_with_this_value[last()]/following-sibling::*[1]" mode="value_grouping"/>
	</xsl:template>
	<!--

	-->
</xsl:stylesheet>
