<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common" xmlns:m8="http://m8data.com">
	<xsl:output method="html" version="1.0" encoding="UTF-8"/>
	<xsl:include href="../../formulyar/xsl/system_head.xsl"/>
	<xsl:include href="../../formulyar/xsl/system_form.xsl"/>
	<!--		


	-->
	<xsl:template name="Head2">
		<script src="/p/formulyar/js/jquery.min-1.9.0.js"/>
		<script>var source = "";</script>
		<!-- по какой-то причине, если не втавить этот тэг, то предыдущий открывающий тег скрипта не закроется //
		<script src="/system/a/js/xalio.js"/>-->
		<script>var source2 = "";</script>
	</xsl:template>
	<xsl:template name="TitleAndMisk">
		<title><xsl:value-of select="$start/@avatar"/>: Админка</title>
	</xsl:template>
	<!--	


	-->
	<xsl:template name="startBody">
		<xsl:call-template name="footer"/>
		<!--<div style="position: fixed; bottom: 5px; left: 5px; z-index: 1">
			<a href="/teplotn/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">calculator</a>
			<xsl:text> | </xsl:text>
			<a href="/system/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">sys</a>
			<xsl:text> | </xsl:text>
			<a href="/xalio/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}">refresh</a>
			<xsl:text> | </xsl:text>
			<a href="/m8/{substring($fact,1,1)}/{$fact}/{$author}/{$quest}/port.xml">xml</a>
		</div>
		<div style="position: fixed; bottom: 5px; right: 5px; color: gray; z-index: 1">
			<span title="аватар"><xsl:value-of select="$avatar"/></span>
			<xsl:text> |  </xsl:text>	
			<xsl:value-of select="$localtime"/>
			<xsl:if test="$user != 'guest' ">
				<xsl:text> |  </xsl:text>
				<xsl:value-of select="$user"/>
				<xsl:text> |  </xsl:text>
				<a href="/m8/?logout=true" style="color: red">выйти</a>
			</xsl:if>
		</div>-->
		<xsl:apply-templates select="." mode="start"/>
	</xsl:template>
	<!--

	-->
	<xsl:template name="parentLine">
		<xsl:param name="currentFactName"/>
		<xsl:param name="count"/>
		<xsl:variable name="parentQuest" select="m8:path( $currentFactName, 'subject_r' )/*/*[1]"/>
		<xsl:variable name="parentAuthorName" select="name($parentQuest/..)"/>
		<xsl:variable name="parentFactName" select="name($parentQuest)"/>
		<xsl:variable name="parentQuestName" select="name(m8:path( $parentFactName, 'subject_r' )/*/*[1])"/>
		<xsl:choose>
			<xsl:when test="$parentFactName = $currentFactName">
				<xsl:apply-templates select="m8:path( $parentFactName, $parentAuthorName, $parentQuestName, 'port' )/r/*" mode="titleWord"/>
			</xsl:when>
			<xsl:when test="10 > $count">
				<xsl:call-template name="parentLine">
					<xsl:with-param name="currentFactName" select="$parentFactName"/>
					<xsl:with-param name="count" select="$count+1"/>
				</xsl:call-template>
				<xsl:text> / </xsl:text>
				<a href="/a/{$ctrl}{m8:dir( $parentFactName, $parentAuthorName, $parentQuestName )}">
					<xsl:apply-templates select="$parentQuest" mode="titleWord"/>
				</a>
				<xsl:text> </xsl:text>
			</xsl:when>
		</xsl:choose>
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
				<xsl:message> ^ ^ ^ ^ ^ - Зона ссылок наверх - ^ ^ ^ ^ ^ </xsl:message>
				<div>
					<xsl:choose>
						<xsl:when test="m8:path( $fact, 'index' )/role">
							<xsl:message terminate="no">Зеленая карта</xsl:message>
							<div style="background: #EFD; padding: 1em">
								<table style="font-size: 1em;" width="100%">
									<tr>
										<td width="30%">
											<xsl:for-each select="exsl:node-set($parent)/*[position()!=last()]">
												<xsl:if test="position()!=1">
													<xsl:text> / </xsl:text>
												</xsl:if>
												<a href="/a/{$ctrl}{m8:dir( name(), $avatar, . )}" xml:lang="здесь сознательно указываем автором аватар, т.к. в хлебных крошках переход по типам, а они задаются главным юзером">
													<xsl:if test="name()!=.">
														<xsl:attribute name="style">background: #FDD; padding: .1em; margin: .1em</xsl:attribute>
													</xsl:if>
													<xsl:apply-templates select="." mode="simpleName"/>
												</a>
											</xsl:for-each>
										</td>
										<td width="40%" align="center">
											<b>
												<xsl:if test="$fact != $quest">
													<xsl:attribute name="style">background: #FDD; padding: .1em; margin: .1em</xsl:attribute>
												</xsl:if>
												<xsl:apply-templates select="$startPort/r/*" mode="simpleName"/>&#160;<xsl:value-of select="$fact"/>
											</b>
										</td>
										<td width="30%" align="right" valign="top">
											<xsl:choose>
												<xsl:when test="$startPort/r">
													<xsl:variable name="siblings">
														<xsl:for-each select="m8:path( $startTypeName, 'index' )/object/*">
															<xsl:sort select="@time"/>
															<xsl:copy/>
														</xsl:for-each>
													</xsl:variable>
													<xsl:if test="exsl:node-set($siblings)/*[name()=$fact]/preceding-sibling::*">
														<xsl:variable name="predName" select="name(exsl:node-set($siblings)/*[name()=$fact]/preceding-sibling::*[1])"/>
														<a href="/a/{$ctrl}/m8/{substring($predName,1,1)}/{$predName}">
															<xsl:apply-templates select="exsl:node-set($siblings)/*[name()=$fact]/preceding-sibling::*[1]" mode="simpleName"/>&#9668;</a>
													</xsl:if>
													<xsl:choose>
														<xsl:when test="$startTypeName = 'r' ">&#160;&#160;X&#160;&#160;</xsl:when>
														<xsl:otherwise>
															<a href="/a/{$ctrl}{ m8:dir( $startTypeName) }">&#160;&#160;X&#160;&#160;</a>
														</xsl:otherwise>
														<!--, $author, $quest -->
													</xsl:choose>
													<xsl:if test="exsl:node-set($siblings)/*[name()=$fact]/following-sibling::*">
														<xsl:variable name="nextName" select="name(exsl:node-set($siblings)/*[name()=$fact]/following-sibling::*[1])"/>
														<a href="/a/{$ctrl}/m8/{substring($nextName,1,1)}/{$nextName}">&#9658;<xsl:apply-templates select="exsl:node-set($siblings)/*[name()=$fact]/following-sibling::*[1]" mode="simpleName"/>
														</a>
													</xsl:if>
												</xsl:when>
												<xsl:otherwise>
													<a href="/a/{$ctrl}/">X</a>
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</tr>
								</table>
								<br/>
								<xsl:call-template name="quest_port"/>
								<br style="clear: both"/>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>Красная карта</xsl:message>
							<div style="margin: 2em; padding: 1em; background: #FED">
								<div style="float: right">
									<a href="/a/{$ctrl}/">X</a>
								</div>
								<br style="clear: both"/>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:message> v v v v v - Зона ссылок вниз - v v v v v </xsl:message>
		<div style="padding: 3em">
			<table width="100%" style="font-size: .9em;">
				<tr>
					<td align="center" valign="top">
						<xsl:for-each select="m8:path( 'r', 'role2' )/*/*[name()=$fact]">
							<xsl:variable name="actionAuthor" select="name(..)"/>
							<xsl:if test="m8:path( 'r', $actionAuthor, $fact, 'dock' )/*[name() != $fact]">
								<xsl:variable name="firstTypeName" select="name( m8:path( 'r', $actionAuthor, $fact, 'dock' )/*[name() != $fact][1]/*)"/>
								<xsl:variable name="protoTypeName" select="name( m8:path( $firstTypeName, $avatar, $firstTypeName, 'port' )/r/*)"/>
								<b>Внутренние сущности
									</b>
								<div style="padding: 1em">
									<xsl:for-each select="m8:path( 'r', $actionAuthor, $fact, 'dock' )/*[name() != $fact]">
										<xsl:sort select="*/*/@time"/>
										<div>
											<a href="/a/{$ctrl}{m8:dir( name(), $actionAuthor, $fact )}">
												<xsl:value-of select="position()"/>.
													<xsl:text> </xsl:text>
												<xsl:apply-templates select="m8:path( name(), $actionAuthor, $fact, 'port' )/r/*" mode="simpleName"/>
												<xsl:text> </xsl:text>
												<xsl:value-of select="name()"/>
											</a>
										</div>
									</xsl:for-each>
									<div>
										<xsl:text>+</xsl:text>
										<form action="{concat( '/a/', $ctrl, m8:dir( $fact ) )}">
											<select name="r" onchange="this.form.submit()">
												<option/>
												<xsl:for-each select="m8:path( 'r', concat( 'predicate_', $protoTypeName ) )/*[name()=$avatar]/*">
													<xsl:sort select="@time"/>
													<xsl:variable name="currentMatter" select="name()"/>
													<xsl:if test="not( m8:path( 'r', $actionAuthor, $fact, 'dock' )/*[name() != $fact][name(*) = $currentMatter] )">
														<option value="{name()}">
															<xsl:apply-templates select="." mode="titleWord"/>
														</option>
													</xsl:if>
												</xsl:for-each>
											</select>
										</form>
									</div>
								</div>
							</xsl:if>
						</xsl:for-each>
					</td>
					<td align="center" valign="top">
						<xsl:if test="m8:path( $fact,  'index' )/object/*">
							<b>Экземпляры "<xsl:apply-templates select="$start" mode="titleWord"/>"</b>
							<div style="padding: 1em">
								<xsl:for-each select="m8:path( $fact, 'index' )/object/*">
									<xsl:sort select="@time"/>
									<xsl:variable name="subject" select="."/>
									<xsl:variable name="subjectName" select="name()"/>
									<xsl:variable name="position" select="position()"/>
									<xsl:for-each select="m8:path( $fact, concat( '/object_', $subjectName ) )/*[name()=$user]/*">
										<xsl:sort select="name(..)"/>
										<xsl:variable name="currentAuthorName" select="name(..)"/>
										<xsl:variable name="currentQuestName" select="name()"/>
										<div style="font-size: 1.4em; padding: .1em">
											<a href="/a/{$ctrl}/m8/{substring($subjectName,1,1)}/{$subjectName}/{$currentAuthorName}/{$currentQuestName}">
												<xsl:value-of select="$position"/>
												<xsl:text>. </xsl:text>
												<xsl:if test="$subjectName != $currentQuestName">
													<xsl:apply-templates select="." mode="simpleName"/>
													<xsl:text> :: </xsl:text>
												</xsl:if>
												<xsl:if test="$author != $currentAuthorName">
													<xsl:apply-templates select=".." mode="simpleName"/>
													<xsl:text> :: </xsl:text>
												</xsl:if>
												<xsl:apply-templates select="$subject" mode="simpleName"/>
											</a>
											<xsl:if test="$currentAuthorName='guest'">
												<xsl:if test="1200 > $time - @time">&#160;<sup style="color: red">new</sup>
												</xsl:if>
												<xsl:if test="120 > $time - m8:path( $currentQuestName, 'role1' )/*[name()=$currentAuthorName]/*/@time">
													<xsl:text> </xsl:text>
													<sup style="color: magenta">change</sup>
													<embed src="/xalio/mp3/message.mp3" autostart="true" hidden="true" loop="true" width="0" height="0" align="bottom"> </embed>
												</xsl:if>
											</xsl:if>
										</div>
									</xsl:for-each>
								</xsl:for-each>
							</div>
						</xsl:if>
					</td>
				</tr>
			</table>
			<xsl:message>= = = = = = = - Зона упоминаний - = = = = = =</xsl:message>
		</div>
		<div style="color: #777">
			<xsl:if test="m8:path( $fact, 'index' )/role/role1">
				<div>
					<b>Упоминания в роли значения</b>
					<xsl:for-each select="m8:path( $fact, 'role3' )/*[name()=$user]/*">
						<xsl:sort select="@time"/>
						<div>
							<a href="/a/{$ctrl}/m8/{substring(name(),1,1)}/{name()}/{name(..)}" style="color: gray">
								<xsl:apply-templates select="." mode="simpleName"/>
							</a>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
			<xsl:if test="m8:path( $fact, 'index' )/role/role2">
				<br/>
				<div>
					<b>Упоминания в роли параметра</b>
					<xsl:for-each select="m8:path( $fact, 'role2' )/*[name()=$user]/*">
						<xsl:sort select="@time"/>
						<xsl:variable name="cAuthor" select="name(..)"/>
						<xsl:variable name="cQuest" select="name()"/>
						<div>
							<xsl:for-each select="m8:path( $fact, $cAuthor, $cQuest, 'dock' )/*">
								<a href="/a/{$ctrl}{m8:dir( name(), $cAuthor, $cQuest )}" style="color: gray">
									<xsl:apply-templates select="." mode="simpleName"/>
								</a>
							</xsl:for-each>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
			<xsl:if test="m8:path( $fact, 'index' )/role/role1">
				<br/>
				<div>
					<b>Упоминания в роли субъекта</b>
					<xsl:for-each select="m8:path( $fact, 'role1' )/*[name()=$user]/*[name()!=$fact]">
						<xsl:sort select="@time"/>
						<div>
							<a href="/a/{$ctrl}/m8/{substring(name(),1,1)}/{name()}/{name(..)}" style="color: gray">
								<xsl:apply-templates select="." mode="simpleName"/>
							</a>
						</div>
					</xsl:for-each>
				</div>
			</xsl:if>
			<xsl:if test="m8:path( $fact, 'quest' )/*/*">
				<br/>
				<div>
					<b>Упоминания в роли квеста</b>
					<xsl:for-each select="m8:path( $fact, 'quest' )/*[name()=$user]/*[name()!=$fact]">
								<xsl:sort select="@time"/>
								<div>
									<a href="/a/{$ctrl}/m8/{substring(name(),1,1)}/{name()}/{name(..)}/{$fact}" style="color: gray">
										<xsl:apply-templates select="." mode="simpleName"/>
									</a>
								</div>
					</xsl:for-each>
				</div>
			</xsl:if>
		</div>
		<xsl:message> 
									@@@@@ - Зона генерации нового - @@@@@
				</xsl:message>
		<div style="position: fixed; bottom: 50px; left: 50px; font-size: 2em; background-color: green; opacity: 0.5; padding: 1em; padding-bottom: 0; border-radius: 2em; ">
			<form action="/a/{$ctrl}{m8:dir($fact)}/">
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
		</div>
		<div style="position: fixed; bottom: 50px; right: 50px; font-size: 2em; background-color: green; width: 2em; height: 2em; border-radius: 2em; padding-top: .2em; padding-right: .2em; opacity: 0.5">
			<xsl:choose>
				<xsl:when test="$fact!=$quest">
					<a style="color: white; margin-top: auto" href="{$startID}/?a={$fact}">+</a>
				</xsl:when>
				<xsl:otherwise>
					<a style="color: white; margin-top: auto" href="/a/{$ctrl}/m8/?a={$fact}">+</a>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		<xsl:message> 
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
						<xsl:choose>
							<xsl:when test="$startIndex/*[name()!='subject']">
								<table>
									<xsl:for-each select="$startPort/*">
										<xsl:sort select="name()"/>
										<xsl:variable name="pName" select="name()"/>
										<tr>
											<th valign="top" align="right">
												<a href="/a/{$ctrl}/m8/{substring($pName,1,1)}/{$pName}">
													<span style="font-size: .8em; color: black">
														<xsl:choose>
															<xsl:when test="$pName = 'i' ">имя</xsl:when>
															<xsl:when test="$pName = 'n' ">файл</xsl:when>
															<xsl:when test="$pName = 'd' ">описание</xsl:when>
															<xsl:when test="$pName = 'r' ">перемещение</xsl:when>
															<xsl:when test="$pName=$fact">по умолчанию</xsl:when>
															<xsl:otherwise>
																<xsl:apply-templates select="." mode="simpleName"/>
															</xsl:otherwise>
														</xsl:choose>
													</span>
												</a>
											</th>
											<td valign="top" align="left">
												<xsl:for-each select="*">
													<table>
														<tr>
															<td>
																<xsl:call-template name="editParamOfPort">
																	<xsl:with-param name="predicateName" select="$pName"/>
																	<xsl:with-param name="objectElement" select="$startPort"/>
																</xsl:call-template>
															</td>
															<td valign="top">
																<a href="/a/{$ctrl}/m8/{substring(name(),1,1)}/{name()}">q</a>
															</td>
															<td valign="top">
																<xsl:choose>
																	<xsl:when test="$pName = 'r' ">
																		<xsl:variable name="typeParent">
																			<xsl:message>	 typeParent  </xsl:message>
																			<xsl:call-template name="getParent">
																				<xsl:with-param name="currentFactName" select="$factTypeName"/>
																			</xsl:call-template>
																		</xsl:variable>
																		<xsl:variable name="typeParentName" select="name(exsl:node-set($typeParent)/*[last()-1])"/>
																		<xsl:if test="count(exsl:node-set($typeParent)/*) > 1">
																			<!--<xsl:variable name="newTypeName" select="name(exsl:node-set($parent)/*[last()-1])"/>-->
																			<xsl:variable name="newTypeTitle">
																				<xsl:apply-templates select="exsl:node-set($typeParent)/*[last()-1]" mode="simpleName"/>
																			</xsl:variable>
																			<!-- select="name(exsl:node-set($parent)/*[last()-1])"/>-->
																			<a href="{$startID}/?r={$typeParentName}" title="{$newTypeTitle}">^</a>
																		</xsl:if>
																		<xsl:text> </xsl:text>
																		<a href="/a/{$ctrl}{m8:dir( $factTypeName )}/?a0={name($startPort/r/*/*)}&amp;a5={$quest}">
																			<b>x</b>
																		</a>
																	</xsl:when>
																	<xsl:otherwise>
																		<a href="{$startID}/?a0={name(*)}">x</a>
																	</xsl:otherwise>
																</xsl:choose>
															</td>
															<td valign="top">
																<xsl:if test="$adminMode">
																	<sup>
																		<a href="/m8/{substring(name(),1,1)}/{name()}/value.xml" style="color:gray; font-size:.6em">
																			<xsl:value-of select="name()"/>
																		</a>
																	</sup>
																</xsl:if>
															</td>
														</tr>
													</table>
												</xsl:for-each>
											</td>
										</tr>
									</xsl:for-each>
								</table>
							</xsl:when>
							<xsl:otherwise>
								<a href="/a/{$ctrl}{m8:dir( $factTypeName )}/?a0={name($startPort/r/*/*)}&amp;a5={$quest}">удалить объект</a>
							</xsl:otherwise>
						</xsl:choose>
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
						<br/>Добавление свойства:
					<form action="{$startID}/">
							<select name="a2" onchange="this.form.submit()">
								<option/>
								<xsl:if test="not($startPort[name()='i'])">
									<option value="i">имя</option>
								</xsl:if>
								<xsl:if test="not($startPort[name()='d'])">
									<option value="d">описание</option>
								</xsl:if>
								<xsl:if test="not($startPort[name()='n'])">
									<option value="n">структура</option>
								</xsl:if>
								<xsl:if test="not($startPort[name()=$fact])">
									<option value="{$fact}">начало</option>
								</xsl:if>
								<xsl:for-each select="m8:path( $avatar )/*">
									<xsl:sort select="@name"/>
									<xsl:variable name="typeName">
										<xsl:value-of select="name( m8:path( name(), 'role3' )/*[name()=$avatar]/* )"/>
									</xsl:variable>
									<option value="{$typeName}">
										<xsl:apply-templates select="m8:path( name(), 'role3' )/*[name()=$avatar]/*" mode="simpleName"/>
									</option>
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
