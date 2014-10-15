<%@ page language="java"   pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7"/>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" >
		<link href="/SDDY/CSS/comm2.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="JS/comm.js"></script>
		<script type="text/javascript" src="My97DatePicker/WdatePicker.js"></script>
		<script src="maps/libs/SuperMap.Include.js"></script> 
		<script type="text/javascript" src="jquery-easyui-1.3.2/jquery-1.8.0.min.js"></script>
		<script type="text/javascript" src="jquery-easyui-1.3.2/jquery.easyui.min.js"></script>
		<script type="text/javascript" src="jquery-easyui-1.3.2/locale/easyui-lang-zh_CN.js"></script>
		<link rel="stylesheet" type="text/css" href="jquery-easyui-1.3.2/themes/default/easyui.css"/>
		<link rel="stylesheet" type="text/css" href="jquery-easyui-1.3.2/themes/icon.css"/>
	 <script type="text/javascript">
        var map, layer, vectorLayer,drawPoint, markerLayer,
		    style = {
                pointRadius: 200,
                externalGraphic: "../resource/controlImages/marker-gold.png",
                pointerEvents: "visiblePainted",
                fillColor: "#304DBE",
                fillOpacity: 0.8				
            }

		 // 设置访问的GIS服务地址
          var url = "${MAPSERVER}";
        
         function onPageLoad() {
			// 创建Vector图层，用于显示绘制的几何对象
			vectorLayer = new SuperMap.Layer.Vector("Vector Layer");
            // 创建markers图层，显示查询结果
			markerLayer = new SuperMap.Layer.Markers("Markers");
			// 创建绘制面的控件
            drawPoint = new SuperMap.Control.DrawFeature(vectorLayer, SuperMap.Handler.Point);     
            drawPoint.events.on({"featureadded": drawCompleted});
			// 创建图层对象
            layer = new SuperMap.Layer.TiledDynamicRESTLayer("map", url, {transparent: true, cacheEnabled: true}, {maxResolution:"auto"}); 
           
			//向map添加图层
			layer.events.on({"layerInitialized": addLayer}); 

			// 创建地图对象
           map = new SuperMap.Map("map",{controls: [
                      new SuperMap.Control.LayerSwitcher(),
                      new SuperMap.Control.ScaleLine(),
                      new SuperMap.Control.PanZoomBar(),
                      new SuperMap.Control.Navigation({
                          dragPanOptions: {
                              enableKinetic: true
                          }}),
                      drawPoint]
            });
        }

		// 加载图层
        function addLayer() {
			// 向Map添加图层
            map.addLayers([layer,vectorLayer,markerLayer]);
            map.setCenter(new SuperMap.LonLat(0,0), 0);
        }
		// 激活绘制面对象的操作
		 function drawGeometry() {
            //先清除上次的显示结果
           vectorLayer.removeAllFeatures();
			markerLayer.clearMarkers();
            drawPoint.activate();
        }

		// 绘制面对象结束后处理函数,执行几何查询
		function drawCompleted(evnetArg){
			drawPoint.deactivate();
             // 获取绘制的对象，并显示在vector图层上
			var feature = new SuperMap.Feature.Vector();
            feature.geometry = evnetArg.feature.geometry,
            feature.style = style;
            vectorLayer.addFeatures(feature);
			
			 //FilterParameter 必设 name（查询地图图层名）
            var queryParam = new SuperMap.REST.FilterParameter({
                name: "地块_Point@SDDY_GIS",
				fields:["SMX","SMY","SMID","NAME","SNAME"]
            });

			var queryByDistanceParams = new SuperMap.REST.QueryByDistanceParameters({
						queryParams:[queryParam],
						returnContent: true,
						distance: 1000,
						geometry: feature.geometry
					}); 
			
			var queryByDistanceService = new SuperMap.REST.QueryByDistanceService(url);
			queryByDistanceService.events.on({
						"processCompleted": processCompleted,
						"processFailed": processFailed
					});
			queryByDistanceService.processAsync(queryByDistanceParams);
        }
		// 获取查询结果
        function processCompleted(queryEventArgs) {
            var result = queryEventArgs.result;

			//显示查找到的矢量要素
			if (result && result.totalCount>0) {
					var resultTable = "";
					for	(var i = 0;	i < result.recordsets.length; i++) {											
						if (result.recordsets[i].features) {
							var arrFields = new Array();
							var intFieldCount = result.recordsets[i].fields.length;
							resultTable += "<table align='left' style='width: 600px' border='1'>";
							var strTableHead = ""; 
							// 将字段名称列于表格首行
							for (var n = 0;n < intFieldCount;n++)
							{ 										
										var fieldName = result.recordsets[i].fields[n];
										strTableHead += "<td>";
										strTableHead += fieldName;
										strTableHead += "</td>";
										arrFields.push(fieldName);
							}
							resultTable += "<tr>" + strTableHead + "</tr>";
							for(var	k=0;k<result.recordsets[i].features.length;k++){
								// 获取Geometry 将其显示在Markers Layer上。
								var feature =  result.recordsets[i].features[k];
								var point = result.recordsets[i].features[k].geometry,
                                size = new SuperMap.Size(44, 33),
                                offset = new SuperMap.Pixel(-(size.w/2), -size.h),
                                icon = new SuperMap.Icon("resource/controlImages/marker.png", size, offset);
								markerLayer.addMarker(new SuperMap.Marker(new SuperMap.LonLat(point.x, point.y), icon));
								// 将属性值放入表格中
								resultTable += "<tr>";
								for(var	j=0;j<intFieldCount;j++){
									resultTable += "<td>";
									var fName =arrFields[j]
									resultTable += feature.attributes[fName];
									resultTable += "</td>";
								}
								resultTable += "</tr>";
							}
							resultTable += "</table>";
						}
					}
				}
				else{
							resultTable = "<p>无查询结果！</p>";
				}
                document.getElementById("queryResultPanel").innerHTML = resultTable;
		}
        function processFailed(e) {
            alert(e.error.errorMsg);
        }
        function clearFeatures() {
            //先清除上次的显示结果
            vectorLayer.removeAllFeatures();
            vectorLayer.refresh();
        }
    </script>
  </head>
  <body onload=onPageLoad() >
    <div id="core" >
         <input name="queryByDis" type="button" onClick="drawGeometry()" value="距离查询">
		 <div id="map" style="position:relative; left:1px; right:0px; width:1000px; height:800px;">     </div>
	 <div id="queryResultPanel" style="width:600px;left:10px;top:420px;">			
						
		</div>
  </body>
</html>

 
