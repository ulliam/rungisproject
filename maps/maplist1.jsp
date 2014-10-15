<%@ page language="java"   pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<html>
	<head>
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
  var map, layer, vectorLayer,drawPolygon, markerLayer,
		    style = {
                strokeColor: "#333333",
                strokeWidth: 2,
                pointerEvents: "visiblePainted",
                fillColor: "#304DBE",
                fillOpacity: 0.8				
            },
            stylered = {
                strokeColor: "#FF0000",
                strokeWidth: 1,
                pointerEvents: "visiblePainted",
                fillColor: "#FF0000",
                fillOpacity: 0.8				
            },
            styleyellow = {
                strokeColor: "#FFFF00",
                strokeWidth: 1,
                pointerEvents: "visiblePainted",
                fillColor: "#FFFF00",
                fillOpacity: 0.8				
            },
            styleorange = {
                strokeColor: "#FF4500",
                strokeWidth: 1,
                pointerEvents: "visiblePainted",
                fillColor: "#FF4500",
                fillOpacity: 0.8				
            };

		 // 设置访问的GIS服务地址
          var url = "${MAPSERVER}";
        
         function onPageLoad() {
			// 创建客户端矢量图层，用于显示绘制的几何对象
			vectorLayer = new SuperMap.Layer.Vector("Vector Layer");
            // 创建marks图层，显示查询结果
			markerLayer = new SuperMap.Layer.Markers("Markers");
			// 创建绘制面的控件
            layer = new SuperMap.Layer.TiledDynamicRESTLayer("dongying", url, {transparent: true, cacheEnabled: true}, {maxResolution:"auto"}); 
			//向map添加图层
			layer.events.on({"layerInitialized": addLayer}); 

			// 创建地图对象
           map = new SuperMap.Map("map",{minScale:1/70000,
			        maxScale:4.828188529610221e-4,
			        restrictedExtent:new SuperMap.Bounds(525280.323131,4207350.897281,557487.927211,4224868.702635) ,
			        controls: [
                      new SuperMap.Control.LayerSwitcher(),
                      new SuperMap.Control.ScaleLine(),
                      new SuperMap.Control.PanZoomBar(),
                      new SuperMap.Control.Navigation({
                          dragPanOptions: {
                              enableKinetic: true
                          }})]
            });
			// 加载鹰眼控件
            map.addControl(new SuperMap.Control.OverviewMap());
        }
		
		// 加载图层
        function addLayer() {
			// 向Map添加图层
			var pointx=document.getElementById("pointx").value,
			pointy=document.getElementById("pointy").value,
			size = new SuperMap.Size(44, 33),
            offset = new SuperMap.Pixel(-(size.w/2), -size.h),
            icon = new SuperMap.Icon("IMG/supermap/marker.png", size, offset);
            if(pointx!="" && pointy!=""){
			var marker = new SuperMap.Marker(new SuperMap.LonLat(pointx, pointy),icon);            
            markerLayer.addMarker(marker);
            map.addLayers([layer,vectorLayer,markerLayer]);
            map.setCenter(new SuperMap.LonLat(pointx, pointy), 2);
            }
            else{
            map.addLayers([layer,vectorLayer,markerLayer]);
            map.setCenter(new SuperMap.LonLat(534534.39070352 ,4216069.8492462), 1);
            }
            
        }
        
        function clearFeatures() {
            //先清除上次的显示结果
            vectorLayer.removeAllFeatures();
            vectorLayer.refresh();
            markerLayer.clearMarkers();
            closeInfoWin();
        }
        
         function drawPointGeo() {
            //先清除上次的显示结果
            vectorLayer.removeAllFeatures();
            markerLayer.clearMarkers();
            drawPoint.activate();
        }
        
        function drawPointCompleted(evnetArg){
			var feature = new SuperMap.Feature.Vector();
            feature.geometry = evnetArg.feature.geometry,
            feature.style = style;
            vectorLayer.addFeatures(feature);
            document.getElementById("getpointx").value=feature.geometry.x;
            document.getElementById("getpointy").value=feature.geometry.y;
            drawPoint.deactivate();
            }
        
        
      
		
        
    </script>
  </head>
  <body onload=onPageLoad() >
  <table cellpadding="0" CELLSPACING="0" class="toolbartable">
		<tr class="toolbartableline1">
			<td width="10"></td>
			<td>
				<select name="status" id="status">
				<option value="全部">
					全部
				</option>
				<option value="厂名">
					厂名
				</option>
				<option value="危险源">
					危险源
				</option>
				<option value="摄像点">
					摄像点
				</option>
				<option value="罐区">
					罐区
				</option>
				<option value="装置区">
					装置区
				</option>
				<option value="仓库">
					仓库
				</option>
				</select>
				<a href="javascript:void(0)" class="easyui-linkbutton" 
					data-options="iconCls:'icon-dodel'" onclick="clearFeatures();">清除</a>
			</td>
			<td width="10"></td>
		</tr>
	</table>
		<br>
	   	<input  type ="hidden" id="pointx"  value="${param.valuex}">
	  	<input  type ="hidden" id="pointy"  value="${param.valuey}">
	  	<input  type ="hidden" id="getpointx"  value="">
	  	<input  type ="hidden" id="getpointy"  value="">
		<div id="map" style="position:relative;left:0px;right:0px;width:100%;height:100%;">             
     	</div>
	 	<div id="queryResultPanel" style="width:600px;left:10px;top:420px;">			
		</div>
		<input  type ="text" id="pointinformation"  value="">
  </body>
  <c:if test="${! empty msg}">
		<script>
			$.messager.alert('系统提示', '${msg}');
		</script>
	</c:if>
</html>

 
