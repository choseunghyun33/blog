<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
	//----------------------------------------------------------- 컨트롤러
	// 삭제할 boardNo commentNo commentPw 받아오기
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int commentNo = Integer.parseInt(request.getParameter("commentNo"));
	// 디버깅
	System.out.println(boardNo + " <-- boardNo");
	System.out.println(commentNo + " <-- commentNo");
	System.out.println(session.getAttribute("loginId") + " <-- loginId");

	
	
	
	// 권한 없을 시 재요청
	if(session.getAttribute("loginId") == null){
		response.sendRedirect("./index.jsp"); 
		return;
	}
		


	// ----------------------------------------------------------- 서비스
	// 1. DB 연동
	Class.forName("org.mariadb.jdbc.Driver");
	String url = "jdbc:mariadb://3.34.240.0:3306/blog";
	String dbuser = "root";
	String dbpw = "1234";
	Connection conn = DriverManager.getConnection(url, dbuser, dbpw);
	// 디버깅
	System.out.println(conn + " <-- conn");
	
	// 2. 쿼리담기
	// 삭제 deleteStmt
	String deleteSql = "DELETE FROM comment WHERE board_no = ? AND comment_no = ? AND id = ?";
	PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
	// ? setter
	deleteStmt.setInt(1, boardNo);
	deleteStmt.setInt(2, commentNo);
	deleteStmt.setString(3, (String)session.getAttribute("loginId"));
	// 디버깅
	System.out.println(deleteStmt + " <-- deleteStmt");
	
	// 3. 쿼리실행
	int row = deleteStmt.executeUpdate();
	// 디버깅
	if(row == 1){ // delete 성공
		System.out.println("삭제성공!!!");
	} else { // delete 실패
		System.out.println("삭제실패!!!");
	}
	
	// 4. 재요청
	response.sendRedirect("./boardOne.jsp?boardNo=" + boardNo);
	
	// 5. DB자원해제
	deleteStmt.close();
	conn.close();
%>