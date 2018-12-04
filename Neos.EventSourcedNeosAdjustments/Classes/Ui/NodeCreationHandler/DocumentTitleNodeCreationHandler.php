<?php
namespace Neos\EventSourcedNeosAdjustments\Ui\NodeCreationHandler;

/*
 * This file is part of the Neos.Neos.Ui package.
 *
 * (c) Contributors of the Neos Project - www.neos.io
 *
 * This package is Open Source Software. For the full copyright and license
 * information, please view the LICENSE file which was distributed with this
 * source code.
 */

use Neos\ContentRepository\Domain\Projection\Content\TraversableNodeInterface;
use Neos\EventSourcedContentRepository\Domain\Context\Node\Command\SetNodeProperty;
use Neos\EventSourcedContentRepository\Domain\Context\Node\NodeCommandHandler;
use Neos\EventSourcedContentRepository\Domain\ValueObject\PropertyValue;
use Neos\EventSourcedNeosAdjustments\Ui\ContentRepository\Service\NodeService;
use Neos\Flow\Annotations as Flow;

class DocumentTitleNodeCreationHandler implements NodeCreationHandlerInterface
{
    /**
     * @Flow\Inject
     * @var NodeService
     */
    protected $nodeService;

    /**
     * @Flow\Inject
     * @var NodeCommandHandler
     */
    protected $nodeCommandHandler;

    /**
     * Set the node title for the newly created Document node
     *
     * @param TraversableNodeInterface $node The newly created node
     * @param array $data incoming data from the creationDialog
     * @return void
     */
    public function handle(TraversableNodeInterface $node, array $data)
    {
        if ($node->getNodeType()->isOfType('Neos.Neos:Document')) {
            if (isset($data['title'])) {
                $this->nodeCommandHandler->handleSetNodeProperty(new SetNodeProperty(
                    $node->getContentStreamIdentifier(),
                    $node->getNodeAggregateIdentifier(),
                    $node->getOriginDimensionSpacePoint(),
                    'title',
                    new PropertyValue($data['title'], 'string')
                ));
            }

            $uriPathSegment = $this->nodeService->generateUriPathSegment($node, $data['title']);
            $this->nodeCommandHandler->handleSetNodeProperty(new SetNodeProperty(
                $node->getContentStreamIdentifier(),
                $node->getNodeAggregateIdentifier(),
                $node->getOriginDimensionSpacePoint(),
                'uriPathSegment',
                new PropertyValue($uriPathSegment, 'string')
            ));
        }
    }
}
