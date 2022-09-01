<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
	// 재요청 - 접근 막기
	if(session.getAttribute("loginId") != null){ // 로그인된 사람이 진행되면 안되므로
		response.sendRedirect("./index.jsp");	// 재요청후에
		return; 								// 리턴
	}

	request.setCharacterEncoding("UTF-8");
	String id = request.getParameter("id");
	String pw = request.getParameter("pw");
	
	
	if(id == null || pw == null || id.length() < 4 || pw.length() < 4){
		response.sendRedirect("./index.jsp?errorMsg=Invalid Access");
		return; 
	}
	
	// ----------------------------------------------------------- 서비스
	// 1. DB 연동
	Class.forName("org.mariadb.jdbc.Driver");
	String url = "jdbc:mariadb://localhost:3306/blog";
	String dbuser = "root";
	String dbpw = "1234";
	Connection conn = DriverManager.getConnection(url, dbuser, dbpw);
	// 디버깅
	System.out.println(conn + " <-- conn");
	
	String sql = "SELECT id, level FROM member WHERE id = ? AND pw = PASSWORD(?)";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, id);
	stmt.setString(2, pw);
	ResultSet rs = stmt.executeQuery();
	if(rs.next()){ // 로그인성공
		// setAttribute(String, Object) // value타입이 Object이기때문에 정확히 어떤타입인지 알려준다.
		session.setAttribute("loginId", rs.getString("id")); 	// Object <- String (다형성)
		session.setAttribute("loginLevel", rs.getInt("level")); // Object <- Integer <- int (오토박싱)
		response.sendRedirect("./index.jsp");
	} else { // 로그인실패
		response.sendRedirect("./index.jsp?errorMsg=Invalid ID or PW");
	}
	
	
	// DB자원해제
	rs.close();
	stmt.close();
	conn.close();
%>