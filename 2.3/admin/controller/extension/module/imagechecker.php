<?php
class ControllerExtensionModuleImageChecker extends Controller
{
	private function getMissingImages()
	{
		$rows=array();
		
		$sql ="SELECT p.product_id,pd.name,p.image,p.quantity,p.status FROM ".DB_PREFIX."product p ";
		$sql.="LEFT JOIN ".DB_PREFIX."product_description pd ON p.product_id=pd.product_id WHERE 1=1 ";
		
		if(isset($this->request->post['stock']))
		{
			if($this->request->post['stock']=='with_stock')
			{
				$sql.=" AND p.quantity > 0";
			}
			if($this->request->post['stock']=='no_stock')
			{
				$sql.=" AND p.quantity < 1";
			}
		}
		
		if(isset($this->request->post['status']))
		{
			if($this->request->post['status']=='status_1')
			{
				$sql.=" AND p.status=1";
			}
			
			if($this->request->post['status']=='status_0')
			{
				$sql.=" AND p.status=0";
			}
		}
		
		$result=$this->db->query($sql);
		
		foreach($result->rows as $row)
		{
			$image=DIR_IMAGE.$row['image'];
			if(!@is_array(getimagesize($image)))
			{
				$rows[]=array('product_id'=>$row['product_id'],
							  'name'=>$row['name'],
							  'image'=>$image,
							  'stock'=>$row['quantity'],
							  'status'=>$row['status']);
			}
		}
		return $rows;
	}
	
	
	public function upload()
	{
		header("Content-type: application/json;");
		
		$product_id=(int)$this->request->post['product_id'];
		
		$response=array();
		
		if($product_id!=0 && isset($_FILES["file"]['name']))
		{
			$ext=explode(".",$_FILES["file"]['name']);
			$ext=array_pop($ext);
			$image_path=str_ireplace("//","/",DIR_IMAGE."/".md5($_FILES["file"]['name']).".".$ext);
			
			$done=move_uploaded_file($_FILES["file"]['tmp_name'],$image_path);
			if($done)
			{
				$db_image_path=str_ireplace(str_ireplace("//","/",DIR_IMAGE),"",$image_path);
				
				$this->db->query("UPDATE ".DB_PREFIX."product SET image='".$db_image_path."' WHERE product_id='".$product_id."';");
				$response=array('message'=>'success');
			}
		}
		else
		{
			$response=array('message'=>'error');
		}
		print json_encode($response);
	}
	
	protected function install() 
	{
		$this->load->model('user/user_group');
		$this->model_user_user_group->addPermission($this->user->getId(), 'access', 'module/imagechecker');
		$this->model_user_user_group->addPermission($this->user->getId(), 'modify', 'module/imagechecker');
	}
	public function index()
	{
		$this->load->language("extension/module/imagechecker");
		
		$this->document->setTitle($this->language->get('heading_title'));
	
		$data['rows']=$this->getMissingImages();
		$data['session']=$this->request->get['token'];
		$data['heading_title']=$this->language->get('heading_title');
		
		$data['token']=$this->session->data['token'];
		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');
		$data['selected_status']=isset($this->request->post['status']) ?  $this->request->post['status'] : '';
		$data['selected_stock']=isset($this->request->post['stock']) ?  $this->request->post['stock'] : '';
		$this->response->setOutput($this->load->view('extension/module/imagechecker.tpl',$data));
	}
}
?>