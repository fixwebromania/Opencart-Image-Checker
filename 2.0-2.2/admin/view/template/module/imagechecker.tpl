<?php print $header ?>
<?php print $column_left; ?>
<div id="content">
 <style>
 .action
  {
	text-align:center;
    width: 110px;	
  }
  .status
  {
	  color:green;
  }
  .status0
  {
	  color:green;
  }
  .status-red
  {
	  color:red;
  }
  .custom-col
  {
	  width: 134px;
  }
  .center,
  .center > *
  {
	  text-align: center;
  }
  </style>
  <script>
  function uploadImage(product_id)
  {
	$('#image-upload').remove();
	
	$('body').prepend('<form enctype="multipart/form-data" id="image-upload" style="display: none;"><input type="hidden" name="product_id" value="'+product_id+'" /><input type="file" name="file" /></form>');
	
	$('#image-upload > [name="file"]').on("change",function()
	{
		var formData = new FormData($('#image-upload')[0]);

		$.ajax({
                url : "index.php?route=module/imagechecker/upload&token=<?php print $token; ?>&t="+Date.now(),
                type : 'POST',
                data : formData,
                contentType : false,
                processData : false,
                success: function(r) 
				{
                    if(r.message=='success')
					{
						location.reload();
					}
					else
					{
						alert("ERROR: "+r.message);
					}						
                }
            });
	});
	
	$('#image-upload input[name=\'file\']').trigger('click'); 
  }
  </script>  
  <div class="page-header">
    <div class="container-fluid">
		<h1><?php print $heading_title; ?></h1>
	</div>
  </div>
  <div class="container-fluid">
   <div class="table-responsive">
    <table class="table table-bordered table-hover">
		<thead><td>Product</td><td>Image Path</td><td class="custom-col">Stock</td><td class="custom-col">Status</td></td><td class='action'>Action</td></thead>
		<tr>
			<form id="filter" method="POST" action="index.php?route=module/imagechecker&token=<?php print $token;?>">
			<td></td>
			<td></td>
			<td class="center">
				<select class="form-control" class="form-control" name="stock">
						<option value="">All</option>
						<option value="with_stock" <?php print ($selected_stock=='with_stock'? 'selected':''); ?> >With Stock</option>
						<option value="no_stock" <?php print ($selected_stock=='no_stock'? 'selected':''); ?>>Without Stock</option>
				</select>
			</td>
			<td class="center">
				<select class="form-control" class="form-control" name="status">
						<option value="">All</option>
						<option value="status_1" <?php print ($selected_status=='status_1' ? 'selected':''); ?> >Enabled</option>
						<option value="status_0" <?php print ($selected_status=='status_0'? 'selected':''); ?>>Disabled</option>
				</select>
			</td>
			</form>
			<td class='action'><a class="btn btn-primary" onclick="document.getElementById('filter').submit();">Filter</i></a></td></thead>
		<?php 
			foreach($rows as $row)
			{
				print "<tr><td>".$row['name']."</td><td>".$row['image']."</td><td class='center status".(((int)$row['stock'])<1 ? '-red':'')."'>".$row['stock']."</td><td class='center'>".($row['status']==1 ? '<font color="green">Enabled</font>':'<font color="red">Disabled</font>')."</td><td class='action' ><a _target='blank' class='btn btn-primary' href='index.php?route=catalog/product/edit&token=".$token."&product_id=".$row['product_id']."#tab-image'><i class='fa fa-pencil'></i></a> <a class='btn btn-primary' onclick='uploadImage(".$row['product_id'].")'><i class='fa fa-upload'></i></a></td></tr>".PHP_EOL;
			}
		?>
	</table>		
  </div>
<?php print $footer; ?>